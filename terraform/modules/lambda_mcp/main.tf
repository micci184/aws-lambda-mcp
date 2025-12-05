# ECR Repository for Lambda MCP Server
resource "aws_ecr_repository" "lambda_mcp" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

# ECR Lifecycle Policy - Keep only last 5 images
resource "aws_ecr_lifecycle_policy" "lambda_mcp" {
  repository = aws_ecr_repository.lambda_mcp.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Get ECR image digest to detect image updates
data "aws_ecr_image" "lambda_mcp" {
  repository_name = aws_ecr_repository.lambda_mcp.name
  image_tag       = var.image_tag

  depends_on = [aws_ecr_repository.lambda_mcp]
}

# Lambda Function
resource "aws_lambda_function" "mcp_server" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_mcp.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_mcp.repository_url}:${var.image_tag}"
  timeout       = var.timeout
  memory_size   = var.memory_size
  architectures = ["arm64"]

  # Detect image updates by tracking digest
  source_code_hash = trimprefix(data.aws_ecr_image.lambda_mcp.id, "sha256:")

  environment {
    variables = {
      HOME = "/tmp"
    }
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.cloudwatch_logs_read,
    aws_iam_role_policy_attachment.cloudwatch_metrics_read,
  ]
}

# Lambda Function URL (No Auth)
resource "aws_lambda_function_url" "mcp_server" {
  function_name      = aws_lambda_function.mcp_server.function_name
  authorization_type = "NONE"

  cors {
    allow_origins     = var.cors_allow_origins
    allow_methods     = ["POST"]
    allow_headers     = ["content-type", "mcp-session-id"]
    expose_headers    = ["mcp-session-id"]
    max_age           = 86400
    allow_credentials = true
  }
}

# Permission for Function URL to invoke Lambda
resource "aws_lambda_permission" "function_url" {
  statement_id           = "FunctionURLAllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.mcp_server.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}
