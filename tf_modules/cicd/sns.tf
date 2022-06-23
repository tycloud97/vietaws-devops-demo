resource "aws_sns_topic" "code_deploy" {
  name = "${var.environment_name}-${var.app_name}-code-deploy-sns"
}

resource "aws_sns_topic_subscription" "code_deploy_subscription" {
  topic_arn = aws_sns_topic.code_deploy.arn
  protocol  = "email"
  endpoint  = "typrone1@gmail.com"
}