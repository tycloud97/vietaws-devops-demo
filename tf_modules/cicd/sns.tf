resource "aws_sns_topic" "code_deploy" {
  name       = "${var.project_name}-CodeDeploy-SNS"
}

resource "aws_sns_topic_subscription" "code_deploy_subscription" {
  topic_arn = aws_sns_topic.code_deploy.arn
  protocol  = "email"
  endpoint  = "typrone1@gmail.com"
}