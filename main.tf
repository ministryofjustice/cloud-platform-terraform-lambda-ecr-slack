
provider "aws" {
  region = "eu-west-2"
}

data "aws_iam_policy_document" "lambda_assume" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "template_file" "policy_lambda" {
  template = file("${path.module}/templates/ecr-scan.json.tpl")
}


resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

  tags = {
    tag-key = "lambda_role"
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = var.lambda_policy_name
  description = "policy for lambda function"
  policy      = data.template_file.policy_lambda.rendered
}


resource "aws_iam_policy_attachment" "policy_attach" {
  name       = "policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = var.lambda_zip_output_location
  source_dir = var.lambda_zip_source_location
}


resource "aws_lambda_function" "lambda_function" {
  filename              = var.lambda_zip_output_location
  function_name         = var.function_name
  handler               = var.handler
  role                  = aws_iam_role.lambda_role.arn
  runtime               = "python3.8"

  environment {
    variables = {
      ECR_REPO = var.ecr_repo
      SLACK_TOKEN = var.slack_token
    }
  }
}
