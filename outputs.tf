output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.lambda_function.id
}

output "arn" {
  description = "arn of lambda function"
  value       = aws_lambda_function.lambda_function.arn
}