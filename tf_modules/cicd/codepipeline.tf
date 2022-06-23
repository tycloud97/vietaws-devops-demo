resource "aws_iam_role" "codepipeline_role" {
  name = "${var.environment_name}-${var.app_name}-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {

  name   = "${var.environment_name}-${var.app_name}-codepipeline-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = <<EOF
{
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Action": [
                                "*"
                            ],
                            "Resource": "*",
                            "Effect": "Allow"
                        }
                    ]
                }
EOF
}


resource "aws_codepipeline" "codepipeline" {
  count = var.enabled ? 1 : 0

  name     = "${var.environment_name}-${var.app_name}-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      region           = data.aws_region.current.name
      run_order        = 1
      configuration = {
        PollForSourceChanges = false
        RepositoryName       = aws_codecommit_repository.codecommit.repository_name
        BranchName           = var.code_commit_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild[0].name
      }
      region = data.aws_region.current.name
    }


  }
  stage {
    name = "DeployNonProduction"

    action {
      name            = "DeployDev"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1
      configuration = {
        ApplicationName     = "${aws_codedeploy_app.app[0].name}"
        DeploymentGroupName = "${aws_codedeploy_deployment_group.app-deployment-group-dev[0].deployment_group_name}"
      }
      region = data.aws_region.current.name
    }

    action {
      name            = "DeployStaging"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1
      configuration = {
        ApplicationName     = "${aws_codedeploy_app.app[0].name}"
        DeploymentGroupName = "${aws_codedeploy_deployment_group.app-deployment-group-staging[0].deployment_group_name}"
      }
      region = data.aws_region.current.name
    }
  }


  stage {
    name = "DeployProd"
    action {
      name      = "ApproveProdDeployment"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1
    }

    action {
      name            = "DeployProd"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 2
      configuration = {
        ApplicationName     = "${aws_codedeploy_app.app[0].name}"
        DeploymentGroupName = "${aws_codedeploy_deployment_group.app-deployment-group-prod[0].deployment_group_name}"
      }
      region = data.aws_region.current.name
    }

  }
}
