

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "ecr-scanning-${var.function_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries",
      "s3:Get*",
      "s3:List*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "ecr-scanning-${var.function_name}"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source_dir  = "${path.module}/resources/lambda"
}

data "kubernetes_secret" "slack_cred" {
  metadata {
    name      = var.slack_secret
    namespace = var.namespace
  }
}

resource "aws_lambda_function" "lambda_function" {
  filename      = "${path.module}/lambda.zip"
  function_name = var.function_name
  handler       = var.handler
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"

  environment {
    variables = {
      ECR_REPO    = data.kubernetes_secret.slack_cred.data["token"]
      SLACK_TOKEN = data.kubernetes_secret.slack_cred.data["repo"]
    }
  }

  depends_on = [data.archive_file.lambda_zip, data.kubernetes_secret.slack_cred]
}


resource "aws_cloudwatch_event_rule" "aws_cloudwatch_event_rule" {
  name          = var.function_name
  description   = "Event triggered when image is pushed to ECR"
  event_pattern = file("${path.module}/resources/event-pattern.json")
}

resource "aws_cloudwatch_event_target" "aws_cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.aws_cloudwatch_event_rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambda_function.arn
}
