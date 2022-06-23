resource "aws_codebuild_project" "tf-plan" {
  name         = "${var.environment_name}-tf-cicd-plan"
  description  = "Plan stage for terraform"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:1.2.3"
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
      value = "dev"
    }

    environment_variable {
      name  = "STAGE"
      value = "dev"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-plan-staging" {
  name         = "${var.environment_name}-tf-cicd-plan-staging"
  description  = "Plan stage for terraform"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:1.2.3"
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
      value = "827539266883-terraform-backend-devops-staging"
    }

    environment_variable {
      name  = "TF_S3_BACKEND_BUCKET_PATH"
      value = "staging"
    }

    environment_variable {
      name  = "STAGE"
      value = "staging"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-plan-prod" {
  name         = "${var.environment_name}-tf-cicd-plan-prod"
  description  = "Plan stage for terraform"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:1.2.3"
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
      value = "827539266883-terraform-backend-devops-prod"
    }

    environment_variable {
      name  = "TF_S3_BACKEND_BUCKET_PATH"
      value = "prod"
    }

    environment_variable {
      name  = "STAGE"
      value = "prod"
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
    image                       = "hashicorp/terraform:1.2.3"
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
      value = "dev"
    }

    environment_variable {
      name  = "STAGE"
      value = "dev"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-apply-staging" {
  name         = "${var.environment_name}-tf-cicd-apply-staging"
  description  = "Apply stage for terraform"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:1.2.3"
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
      value = "827539266883-terraform-backend-devops-staging"
    }

    environment_variable {
      name  = "TF_S3_BACKEND_BUCKET_PATH"
      value = "staging"
    }

    environment_variable {
      name  = "STAGE"
      value = "staging"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-apply-prod" {
  name         = "${var.environment_name}-tf-cicd-apply-prod"
  description  = "Apply stage for terraform"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:1.2.3"
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
      value = "827539266883-terraform-backend-devops-prod"
    }

    environment_variable {
      name  = "TF_S3_BACKEND_BUCKET_PATH"
      value = "prod"
    }

    environment_variable {
      name  = "STAGE"
      value = "prod"
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
      name             = "PlanDev"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["tf-code"]
      output_artifacts = ["tf-plan"]
      run_order        = 1
      configuration = {
        ProjectName = "${aws_codebuild_project.tf-plan.id}"
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
      name            = "DeployDev"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      owner           = "AWS"
      input_artifacts = ["tf-plan"]
      configuration = {
        ProjectName = "${aws_codebuild_project.tf-apply.id}"
      }
    }



  }


  stage {

    name = "DeployStaging"

    action {
      name             = "PlanStaging"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      run_order        = 1
      input_artifacts  = ["tf-code"]
      output_artifacts = ["tf-plan-staging"]
      configuration = {
        ProjectName = "${aws_codebuild_project.tf-plan-staging.id}"
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
      name            = "DeployStaging"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      owner           = "AWS"
      input_artifacts = ["tf-plan-staging"]
      configuration = {
        ProjectName = "${aws_codebuild_project.tf-apply-staging.id}"
      }
    }
  }

  stage {
    name = "DeployProd"

    action {
      name             = "PlanProd"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      run_order        = 1
      input_artifacts  = ["tf-code"]
      output_artifacts = ["tf-plan-prod"]
      configuration = {
        ProjectName = "${aws_codebuild_project.tf-plan-prod.id}"
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
      name            = "DeployProd"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      owner           = "AWS"
      input_artifacts = ["tf-plan-prod"]
      configuration = {
        ProjectName = "${aws_codebuild_project.tf-apply-prod.id}"
      }
    }
  }
}