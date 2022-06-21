resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-${var.app_name}"

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

  name   = "codepipeline-${var.app_name}"
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


# resource "aws_cloudwatch_event_rule" "codecommit_rule" {
#   name        = "viet-aws-codecommit-${var.app_name}"
#   description = "Event Rule for any commit to codecommit of Bookstore App - ${var.app_name}"

#   event_pattern = <<EOF
# {
#   "source": ["aws.codecommit"],
#   "detail-type": ["CodeCommit Repository State Change"],
#   "resources": ["${aws_codecommit_repository.codecommit.arn}"],
#   "detail": {
#    "event": ["referenceCreated","referenceUpdated"],
#    "referenceType": ["branch"],
#    "referenceName": ["${var.code_commit_branch}"]
#    }
# }
# EOF
# }

# resource "aws_cloudwatch_event_target" "codecommit_rule_target" {
#   rule      = aws_cloudwatch_event_rule.codecommit_rule.name
#   target_id = "TriggerCodePipeline"
#   arn       = aws_codepipeline.codepipeline.arn
#   role_arn  = aws_iam_role.cloudwatch_target_role.arn
# }

resource "aws_iam_role" "cloudwatch_target_role" {

  name = "cloudwatchtarget-${var.app_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_target_role_policy" {
    count = var.enabled ? 1 : 0

  name   = "cloudwatchtarget-${var.app_name}"
  role   = aws_iam_role.cloudwatch_target_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "codepipeline:StartPipelineExecution",
      "Resource": "${aws_codepipeline.codepipeline[0].arn}"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "codepipeline" {
    count = var.enabled ? 1 : 0

  name     = "viet-aws-codepipeline-${var.app_name}"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  # stage {
  #   name = "Source"

  #   action {
  #     name             = "Source"
  #     category         = "Source"
  #     owner            = "AWS"
  #     provider         = "CodeStarSourceConnection"
  #     version          = "1"
  #     output_artifacts = ["SourceArtifact"]
  #     region           = data.aws_region.current.name
  #     namespace        = "SourceVariables"
  #     run_order        = 1
  #     configuration = {
  #       FullRepositoryId     = "tycloud97/vietaws-devops-demo"
  #       BranchName           = "master"
  #       ConnectionArn        = "arn:aws:codestar-connections:ap-southeast-1:827539266883:connection/bb6244c5-3938-42f7-a897-42c58212d5ef"
  #       OutputArtifactFormat = "CODE_ZIP"
  #     }
  #   }
  # }

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
      namespace        = "SourceVariables"
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
      region    = data.aws_region.current.name
      namespace = "BuildVariables"
    }

    
  }
  stage {
    name = "DeployDevelopment"

    # action {
    #   name             = "DeployDevelopment"
    #   category         = "Build"
    #   owner            = "AWS"
    #   provider         = "CodeBuild"
    #   input_artifacts  = ["SourceArtifact"]
    #   output_artifacts = ["DeployArtifact"]
    #   version          = "1"
    #   run_order        = 1
    #   configuration = {
    #     ProjectName = aws_codebuild_project.codebuilddevdeployment.name
    #   }
    #   region    = data.aws_region.current.name
    #   namespace = "DeployVariables"
    # }

    action {
      name            = "DeployCodePipeline"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1
      configuration = {
        ApplicationName     = "${var.app_name}-App"
        DeploymentGroupName = "${var.app_name}-DG"
      }
      region = data.aws_region.current.name
    }

     action {
      name            = "DeployCodePipelineStaging"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 2
      configuration = {
        ApplicationName     = "${var.app_name}-App-staging"
        DeploymentGroupName = "${var.app_name}-DG-staging"
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
      name            = "DeployCodePipelineProd"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 2
      configuration = {
        ApplicationName     = "${var.app_name}-App-prod"
        DeploymentGroupName = "${var.app_name}-DG-prod"
      }
      region = data.aws_region.current.name
    }
   
  }
}
