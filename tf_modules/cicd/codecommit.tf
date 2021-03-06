resource "aws_codecommit_repository" "codecommit" {
  repository_name = var.app_name
  description     = "${var.app_name} Repository"
}

resource "aws_cloudwatch_event_rule" "codecommit_rule" {

  name        = "${var.environment_name}-${var.app_name}-codecommit-rule"
  description = "Event Rule for any commit to codecommit of App - ${var.app_name}"

  event_pattern = <<EOF
{
  "source": ["aws.codecommit"],
  "detail-type": ["CodeCommit Repository State Change"],
  "resources": ["${aws_codecommit_repository.codecommit.arn}"],
  "detail": {
   "event": ["referenceCreated","referenceUpdated"],
   "referenceType": ["branch"],
   "referenceName": ["${var.code_commit_branch}"]
   }
}
EOF
}

resource "aws_cloudwatch_event_target" "codecommit_rule_target" {
  count = var.enabled ? 1 : 0

  rule      = aws_cloudwatch_event_rule.codecommit_rule.name
  target_id = "TriggerCodePipeline"
  arn       = aws_codepipeline.codepipeline[0].arn
  role_arn  = aws_iam_role.cloudwatch_target_role.arn
}

resource "aws_iam_role" "cloudwatch_target_role" {
  name = "${var.environment_name}-${var.app_name}-cloudwatchtarget"

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
  name   = "${var.environment_name}-${var.app_name}-cloudwatchtarget"
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