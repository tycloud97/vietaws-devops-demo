resource "aws_codebuild_project" "tf-plan" {
  name         = "${var.environment_name}-tf-cicd-plan"
  description  = "Plan stage for terraform"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = "dockerhub"
      credential_provider = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = "github:token"
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "REGION"
      value = "ap-southeast-1"
    }

    environment_variable {
      name  = "TF_S3_BACKEND_BUCKET"
      value = "827539266883-terraform-backend-devops-dev"
    }

    environment_variable {
      name  = "TF_S3_BACKEND_BUCKET_PATH"
      value = "shared"
    }

    environment_variable {
      name  = "STAGE"
      value = "shared"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-apply" {
  name         = "${var.environment_name}-tf-cicd-apply"
  description  = "Apply stage for terraform"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = "dockerhub"
      credential_provider = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = "github:token"
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "REGION"
      value = "ap-southeast-1"
    }

    environment_variable {
      name  = "TF_S3_BACKEND_BUCKET"
      value = "827539266883-terraform-backend-devops-dev"
    }

    environment_variable {
      name  = "TF_S3_BACKEND_BUCKET_PATH"
      value = "shared"
    }

    environment_variable {
      name  = "STAGE"
      value = "shared"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }
}


resource "aws_codepipeline" "cicd_pipeline" {

  name     = "${var.environment_name}-tf-cicd"
  role_arn = aws_iam_role.tf-codepipeline-role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf-code"]
      configuration = {
        FullRepositoryId     = "tycloud97/vietaws-devops-demo"
        BranchName           = "master"
        ConnectionArn        = "arn:aws:codestar-connections:ap-southeast-1:827539266883:connection/bb6244c5-3938-42f7-a897-42c58212d5ef"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      output_artifacts = ["tf-plan"]
      configuration = {
        ProjectName = "${aws_codebuild_project.tf-plan.id}"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-plan"]
      configuration = {
        ProjectName = "${aws_codebuild_project.tf-apply.id}"
      }
    }
  }

}