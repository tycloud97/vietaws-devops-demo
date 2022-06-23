resource "aws_iam_role" "codebuild_iam" {

  name = "${var.environment_name}-${var.app_name}-codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role   = aws_iam_role.codebuild_iam.name
  name   = "${var.environment_name}-${var.app_name}-codebuild-policy"
  policy = <<POLICY
{
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Resource": [
                              "*"
                            ],
                            "Action": [
                                "logs:CreateLogGroup",
                                "logs:CreateLogStream",
                                "logs:PutLogEvents"
                            ]
                        },
                        {
                            "Effect": "Allow",
                            "Resource": [
                              "${aws_s3_bucket.codepipeline_bucket.arn}",
                              "${aws_s3_bucket.codepipeline_bucket.arn}/*"
                            ],
                            "Action": [
                                "s3:PutObject",
                                "s3:GetObject",
                                "s3:GetObjectVersion",
                                "s3:GetBucketAcl",
                                "s3:GetBucketLocation"
                            ]
                        },
                        {
                            "Effect": "Allow",
                            "Action": [
                                "codebuild:CreateReportGroup",
                                "codebuild:CreateReport",
                                "codebuild:UpdateReport",
                                "codebuild:BatchPutTestCases"
                            ],
                            "Resource": "*"
                        }
                    ]
}
POLICY
}


resource "aws_codebuild_project" "codebuild" {
  count = var.enabled ? 1 : 0

  name           = "${var.environment_name}-${var.app_name}-codebuild"
  description    = "CodeBuild project for the App- ${var.app_name}"
  build_timeout  = "5"
  queued_timeout = "5"
  service_role   = aws_iam_role.codebuild_iam.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  badge_enabled = false
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
  source_version = var.code_commit_branch
  tags = {
    Environment = "common"
  }
}
