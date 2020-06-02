# To be use in case the resources need to be created in London
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

module "example_team_ecr_scan_lambda" {
  source                     = "../"

  function_name              = "example-function-name"
  handler                    = "lambda_ecr-scan-slack.lambda_handler"
  lambda_role_name           = "example-team-role-name"
  lambda_policy_name         = "example-team-policy-name"
  slack_token                = var.slack_token
  ecr_repo                   = var.ecr_repo
}


