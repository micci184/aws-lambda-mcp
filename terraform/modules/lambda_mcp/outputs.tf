output "function_url" {
  description = "Lambda Function URL endpoint"
  value       = aws_lambda_function_url.mcp_server.function_url
}

output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.mcp_server.function_name
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.mcp_server.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.lambda_mcp.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.lambda_mcp.name
}

output "iam_role_arn" {
  description = "IAM role ARN for the Lambda function"
  value       = aws_iam_role.lambda_mcp.arn
}

