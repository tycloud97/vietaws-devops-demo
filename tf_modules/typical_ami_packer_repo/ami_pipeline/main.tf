## GitHub Connection Stuff
data "aws_codestarconnections_connection" "github_connection" {
  arn = "arn:aws:codestar-connections:ap-southeast-1:827539266883:connection/bb6244c5-3938-42f7-a897-42c58212d5ef"
}

## IAM Stuff

data "aws_iam_policy_document" "codepipeline_ami_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "template_file" "codepipeline_policy_template" {
  template = file("./files/codepipeline_policy.json.tpl")
  vars = {
    bucket                 = aws_s3_bucket.ami_pipeline_artifact_store.arn
    codebuild_project      = aws_codebuild_project.build_ami_packer.arn
    codebuild_test_project = aws_codebuild_project.validate_packer_build.arn
    codestar_conn          = data.aws_codestarconnections_connection.github_connection.arn
    codebuild_ssm_project  = aws_codebuild_project.store_ssm_parameter.arn
  }
}

resource "aws_iam_policy" "codepipeline_role_policy" {
  name        = "CodePipeline_ami_pipeline_policy"
  path        = "/"
  description = "Policy for the ami pipeline"
  policy      = data.template_file.codepipeline_policy_template.rendered
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_role_policy.arn
}


resource "aws_iam_role" "codepipeline_role" {
  name               = "ami-packer-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_ami_assume_policy.json
}

data "aws_iam_policy_document" "codebuild_ami_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "template_file" "codebuild_policy_template" {
  template = file("./files/codebuild_policy.json.tpl")
  vars = {
    bucket                 = aws_s3_bucket.ami_pipeline_artifact_store.arn
    codebuild_project      = aws_codebuild_project.build_ami_packer.arn
    codebuild_test_project = aws_codebuild_project.validate_packer_build.arn
    codestar_conn          = data.aws_codestarconnections_connection.github_connection.arn
    codebuild_ssm_project  = aws_codebuild_project.store_ssm_parameter.arn
  }
}

resource "aws_iam_role" "codebuild_assume_role" {
  name               = "ami-packer-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_ami_assume_policy.json
}

resource "aws_iam_policy" "codebuild_role_policy" {
  name        = "CodeBuild_ami_pipeline_policy"
  path        = "/"
  description = "Policy for the codebuild ami project"
  policy      = data.template_file.codebuild_policy_template.rendered
}

resource "aws_iam_role_policy_attachment" "allow_codebuild_do_stuff" {
  role       = aws_iam_role.codebuild_assume_role.name
  policy_arn = aws_iam_policy.codebuild_role_policy.arn
}

# Actual Useful stuff
resource "aws_s3_bucket" "ami_pipeline_artifact_store" {
  bucket        = "viet-aws-ami-packer-pipeline-artifact-store"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_all_artifact_bucket" {
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  bucket                  = aws_s3_bucket.ami_pipeline_artifact_store.id
}


resource "aws_codepipeline" "ami_pipeline" {
  name     = "ami-packer-demo-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.ami_pipeline_artifact_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.github_connection.arn
        BranchName       = "main"
        FullRepositoryId = "tycloud97/vietaws-devops-demo"
      }

    }
  }

  stage {
    name = "Test_Build"
    action {
      category        = "Test"
      name            = "ValidatePackerBuild"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]
      configuration = {
        "ProjectName" = aws_codebuild_project.validate_packer_build.name
      }
    }
  }

  stage {
    name = "Build_AMI"
    action {
      name             = "Build_AMI"
      run_order        = 1
      owner            = "AWS"
      provider         = "CodeBuild"
      category         = "Build"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        "ProjectName" = aws_codebuild_project.build_ami_packer.name
      }
    }

    action {
      name      = "ManualApproval"
      run_order = 2
      category  = "Approval"
      owner     = "AWS"
      version   = "1"
      provider  = "Manual"
      configuration = {
        "CustomData" = "Approve this AMI to be stored in the SSM Parameter For new EC2s"
      }
    }

    action {
      name            = "Release_AMI"
      run_order       = 3
      owner           = "AWS"
      provider        = "CodeBuild"
      category        = "Build"
      input_artifacts = ["source_output", "build_output"]
      version         = "1"
      configuration = {
        "ProjectName"   = aws_codebuild_project.store_ssm_parameter.name
        "PrimarySource" = "source_output"
      }
    }

  }

}

resource "aws_codebuild_project" "store_ssm_parameter" {
  name          = "store-ssm-parameter"
  description   = "project to take ami id and store it on a SSM parameter"
  service_role  = aws_iam_role.codebuild_assume_role.arn
  build_timeout = "60"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/validate/buildspec_ssm.yml"
  }

}

resource "aws_codebuild_project" "validate_packer_build" {
  name          = "packer-validate-build"
  description   = "The CodeBuild project to validate build packer AMIs"
  service_role  = aws_iam_role.codebuild_assume_role.arn
  build_timeout = "60"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/test/buildspec_test.yml"
  }

}

resource "aws_codebuild_project" "build_ami_packer" {
  name          = "ami-packer-build"
  description   = "The CodeBuild project to build packer AMIs"
  service_role  = aws_iam_role.codebuild_assume_role.arn
  build_timeout = "60"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/buildspec.yml"
  }

}
