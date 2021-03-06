# cloud-platform-terraform-lambda-ecr-slack module

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-lambda/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-lambda/releases)

Terraform module that will create a lambda function in AWS and a relevant role for it to assume.

The lambda 

## Usage


To send notifications to slack of the ECR image scan results, you may insert the following lambda module that creates the slack lambda function and the event bridge. 

The event bridge will be triggered every time there is a scan completed for your ECR repo. The event bridge executes the lambda function which then interacts with slack. A notification containing the scan result will then be sent to your slack channel as per the slack token you specify.

The lambda function incorporates the slack token and ECR repository when it is created. The slack_token and ECR repository must be stored as a kubernetes secret, which you must create as follows:

This secret needs to have the following two keys:

Key 1: repo (without the prefix e.g if the url is 754256621582.dkr.ecr.eu-west-2.amazonaws.com/webops/webops-ecr1:rails, then in this case you need to supply 'webops/webops-ecr1')
Key 2: token

Below is a sample kubernetes secret yaml you can use to create the secret containing the slack token and ECR repo: 

apiVersion: v1
kind: Secret
metadata:
  name: <SLACK_SECRET_NAME>
  namespace: <NAMESPACE>
data:
  repo: <ECR_REPO_BASE64_ENCODED>
  token: <SLACK_TOKEN_BASE64_ENDCODED>

Note that the <ECR_REPO_BASE64_ENCODED> and <SLACK_TOKEN_BASE64_ENDCODED> must be encoded as base64.
e.g 'echo -n <SLACK_TOKEN> | base64'

As this file will contain the slack token it is important that it is encyrpted within the repo that has git-encrypt. Also the file must reside within your own team's repo and not a repo that is shared between teams such as the 'cloud-platform-environments'.

Save the above secret yaml with the desired name and create the secret as follows: 

kubectl create -f <SLACK_SECRET_FILE_NAME>

Lastly, after you have created your kubernetes slack secret as above, move the following lambda module outside the comments section so that it is created alongside your ECR resource. 

```hcl
module "ecr_scan_lambda" {

  source                     = "github.com/ministryofjustice/cloud-platform-terraform-lambda-ecr-slack?ref=v1.0"
  # Function name can be as desired but unique, ideally prefixed with team name and the purpose of the function e.g 'webops_ecr_scan_function'
  function_name              = "example-function-name"
  # Lambda role name as desired but unique ideally prefixed with team name e.g webops_ecr_scan_role
  lambda_role_name           = "example-team-role-name"
  # Lambda policy name as desired but unique ideally prefixed with team name e.g webops_ecr_scan_policy
  lambda_policy_name         = "example-team-policy-name"
  slack_secret               = "<SLACK_SECRET_NAME>"
  namespace                  = "<NAMESPACE>"

}

```




