output "function_url" {
  description = "MCP Server Function URL"
  value       = module.lambda_mcp.function_url
}

output "function_name" {
  description = "Lambda function name"
  value       = module.lambda_mcp.function_name
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = module.lambda_mcp.function_arn
}

output "ecr_repository_url" {
  description = "ECR Repository URL for docker push"
  value       = module.lambda_mcp.ecr_repository_url
}

output "ecr_repository_name" {
  description = "ECR Repository name"
  value       = module.lambda_mcp.ecr_repository_name
}

output "iam_role_arn" {
  description = "IAM role ARN for the Lambda function"
  value       = module.lambda_mcp.iam_role_arn
}

