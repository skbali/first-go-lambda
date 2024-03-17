provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

data "archive_file" "running_ec2_zip" {
  type        = "zip"
  output_path = "./running-ec2/running_ec2.zip"

  source_file = "./running-ec2/code/bootstrap"
}

resource "aws_lambda_function" "running_ec2" {
  function_name = "first-go-lambda"
  handler       = "bootstrap"
  role          = aws_iam_role.first_go_lambda_role.arn

  runtime          = "provided.al2"
  timeout          = 120
  memory_size      = 128
  filename         = data.archive_file.running_ec2_zip.output_path
  source_code_hash = data.archive_file.running_ec2_zip.output_base64sha256

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "every_30_min" {
  name                = "first-go-lambda-30-min"
  schedule_expression = "rate(30 minutes)"
}

resource "aws_cloudwatch_event_target" "first_go_lambda_target" {
  arn  = aws_lambda_function.running_ec2.arn
  rule = aws_cloudwatch_event_rule.every_30_min.name
}

resource "aws_lambda_permission" "first_go_lamabda_perms" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.running_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_30_min.arn
}

