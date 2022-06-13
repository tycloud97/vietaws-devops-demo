{
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:PutObjectAcl",
                "s3:PutObject"
            ],
            "Resource": [
                "${bucket}",
                "${bucket}/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudwatch:*",
                "sns:*",
                "sqs:*",
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": [
                "${codebuild_project}",
                "${codebuild_test_project}",
                "${codebuild_ssm_project}"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:GetConnection",
                "codestar-connections:GetHost",
                "codestar-connections:GetIndividualAccessToken",
                "codestar-connections:GetInstallationUrl",
                "codestar-connections:ListConnections",
                "codestar-connections:ListHosts",
                "codestar-connections:ListInstallationTargets",
                "codestar-connections:ListTagsForResource",
                "codestar-connections:PassConnection",
                "codestar-connections:UseConnection"
            ],
            "Effect": "Allow",
            "Resource": "${codestar_conn}"
        }
    ],
    "Version": "2012-10-17"
}