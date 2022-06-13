resource "aws_ssm_parameter" "latest_ami_id" {
  name        = "/demo/ec2/ami/latest"
  description = "Latest AMI Generated and approved (stable)"
  type        = "String"
  # This will change once the pipeline stage is approved
  value = "ami-xxxxxx"
}

data "aws_iam_policy_document" "lambda_ami_assume_policy_template" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_role_policy" {
  name        = "Lambda_test_Policy"
  description = "Policy for lambda function that will bring up and down a test EC2 with the new AMI"
  policy      = ""
}

resource "aws_iam_role" "lambda_role" {
  name               = "ami-lambda-test"
  assume_role_policy = data.aws_iam_policy_document.lambda_ami_assume_policy_template.json
}

resource "aws_lambda_function" "init_test_ec2" {
  function_name = "test_ami"
  architectures = ["x86_64"]
  role          = aws_iam_role.lambda_role.arn
  handler       = "test_ami.lambda_handler"
}
