# cloud-platform-terraform-lambda-ecr-slack module

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-lambda/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-lambda/releases)

Terraform module that will create a lambda function in AWS and a relevant role for it to assume.

The lambda 

## Usage

**This module will create the resources in the region of the providers specified in the *providers* input.
Be sure to create the relevant providers, see example/main.tf

Bucket first created that will contain the slack tokens. 
```hcl

module "example_team_ecr_scan_lambda" {

  source                     = "git::ssh://git@github.com/ministryofjustice/cloud-platform-terraform-lambda?ref=v1.5"
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


```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| lambda_function_zip_source_path | path of the directory containing the lambda function | string | `""` | yes |
| lambda_function_zip_output_path | name of the zipped archive of the lambda function | string | `""` | yes |
| function_name | AWS name of the lambda function| string | `""` | yes |
| handler | Hanler of the lambda function to be executed| string | `""` | yes |
| providers | provider to use | array of string | default provider | no


## Outputs

| Name | Description |
|------|-------------|
| arn | arn lambda function (e.g can be used as input for event bridge) |


### Lambda bucket policy

The policy referenced by the lambda role is to be created as a json file and saved in the root directory from which you are 
calling the file. e.g create a file named 'policy-lambda.json'. Below is an example policy that gives the lambda role
the relevant permissions to interact with ECR and S3.


```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
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
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
```

The lambda function itself should be named appropriately based on what it does. For example a lambda function that uses python to notiify slack of ECR scanned results would be named as 'lambda_ecr-scan-slack.py'. You can zip this file where the name of the zipped file can be the same name of the lambda file e.g lambda_ecr-scan-slack.zip

Create the zipped file as follows:

```bash
zip lambda_ecr-scan-slack.zip lambda_ecr-scan-slack.py
```

Finally you can then append the name of the zipped file as the 'lambda_function_zip_path' variable when calling the module.
So in this example the value of the 'lambda_function_zip_path' var will be 'lambda_ecr-scan-slack.zip'. See example folder for more details. 




