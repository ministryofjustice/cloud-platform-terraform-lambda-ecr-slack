module "example_team_ecr_scan_lambda" {

  source                     = "git::ssh://git@github.com/ministryofjustice/cloud-platform-terraform-lambda?ref=v1.0"
  function_name              = "example-function-name"
  handler                    = "lambda_ecr-scan-slack.lambda_handler"
  lambda_role_name           = "example-team-role-name"
  lambda_policy_name         = "example-team-policy-name"
  lambda_zip_source_location = "${path.module}/resources/ecr/lambda-zip"
  lambda_zip_output_location = "${path.module}/resources/ecr/lambda-function.zip"
  slack_token                = var.slack_token
  ecr_repo                   = var.ecr_repo
  
  providers = {
    aws = aws.london
  }
}


