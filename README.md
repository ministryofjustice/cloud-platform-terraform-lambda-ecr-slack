# cloud-platform-terraform-lambda module

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-lambda/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-lambda/releases)

Terraform module that will create a lambda function in AWS and a relevant role for it to assume.

The lambda 

## Usage

**This module will create the resources in the region of the providers specified in the *providers* input.
Be sure to create the relevant providers, see example/main.tf

Bucket first created that will contain the slack tokens. 
```hcl

module "webops_ecr_scan_repos_s3_bucket_team" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.1"
    
  team_name              = "cloudplatform"
  business-unit          = "webops"
  application            = "cloud-platform-terraform-s3-bucket-ecr-scan-slack"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platform@digtal.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}


module "example_team_lambda" {
  
  source = "git::ssh://git@github.com/ministryofjustice/cloud-platform-terraform-lambda?ref=v1.5"
  policy_file              = file("policy-lambda.json")
  function_name            = "ecr-lambda-function"
  handler                  = "lambda_ecr-scan-slack.lambda_handler"
  lambda_role_name         = "lambda-role-ecr"
  lambda_policy_name       = "lambda-pol-ecr"
  lambda_zip_source_location = "resources/ecr/lambda-zip"
  lambda_zip_output_location = "resources/ecr/lambda-function.zip"

  providers = {
    aws = aws.london
  }
}



```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| lambda_function_zip_path | name of the zipped archive of the lambda function | string | `""` | yes |
| policy_file | Name of the policy of used by the lambda role | string | `policy-lambda.json` | yes |
| function_name | AWS name of the lambda function| string | `""` | yes |
| handler | Hanler of the lambda function to be executed| string | `""` | yes |
| providers | provider to use | array of string | default provider | no


## Outputs

| Name | Description |
|------|-------------|
| function_name | Name of the lambda function |


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




