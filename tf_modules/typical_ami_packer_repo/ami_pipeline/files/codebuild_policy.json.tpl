{
  "Version": "2012-10-17",
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
                "codebuild:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${codebuild_project}",
                "${codebuild_test_project}",
                "${codebuild_ssm_project}"
            ]
        },
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
      "Sid": "EBSThings",
      "Action": "ebs:*",
      "Effect": "Allow",
      "Resource": ["*"]
    },
    {
      "Sid": "EC2Things",
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": ["*"]
    },
    {
        "Sid": "SSMParameters",
        "Action": [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:PutParameter"
            ],
        "Effect": "Allow",
        "Resource": ["*"]
    }
  ]
}