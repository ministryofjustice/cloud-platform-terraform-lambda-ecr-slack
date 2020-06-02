# To be use in case the resources need to be created in London
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}


module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.0"
  repo_name = "example-team-name-repo"
  team_name = "example-team-name"
  
  # aws_region = "eu-west-2"     # This input is deprecated from version 3.2 of this module
  providers = {
    aws = aws.london
  }
}
 
resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-credentials-output"
    namespace = "my-namespace"
  }

  data = {
    access_key_id     = module.ecr_credentials.access_key_id
    secret_access_key = module.ecr_credentials.secret_access_key
    repo_arn          = module.ecr_credentials.repo_arn
    repo_url          = module.ecr_credentials.repo_url
  }
}

data "kubernetes_secret" "slack_cred" {
  metadata {
    name      = "my-slack-secret-name"
    namespace = "my-namespace"
  }
}

module "ecr_scan_lambda" {

  source                     = "github.com/ministryofjustice/cloud-platform-terraform-lambda-ecr-slack?ref=v1.0"
  function_name              = "example-function-name"
  handler                    = "lambda_ecr-scan-slack.lambda_handler"
  lambda_role_name           = "example-team-role-name"
  lambda_policy_name         = "example-team-policy-name"
  slack_token                = "${data.kubernetes_secret.slack_cred.data["token"]}"
  ecr_repo                   = "${data.kubernetes_secret.slack_cred.data["repo"]}"
}


