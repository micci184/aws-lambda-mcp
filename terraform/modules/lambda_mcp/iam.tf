# IAM Role for Lambda MCP Server
resource "aws_iam_role" "lambda_mcp" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Basic Lambda execution policy (CloudWatch Logs write for Lambda itself)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_mcp.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Logs read access policy
resource "aws_iam_policy" "cloudwatch_logs_read" {
  name        = "${var.function_name}-cloudwatch-logs-read"
  description = "CloudWatch Logs read access for Lambda MCP Server"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:GetLogGroupFields",
          "logs:GetLogRecord",
          "logs:GetQueryResults",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:DescribeQueries"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_read" {
  role       = aws_iam_role.lambda_mcp.name
  policy_arn = aws_iam_policy.cloudwatch_logs_read.arn
}

# CloudWatch Metrics read access policy
resource "aws_iam_policy" "cloudwatch_metrics_read" {
  name        = "${var.function_name}-cloudwatch-metrics-read"
  description = "CloudWatch Metrics read access for Lambda MCP Server"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:GetDashboard",
          "cloudwatch:ListDashboards",
          "cloudwatch:GetInsightRuleReport",
          "cloudwatch:DescribeInsightRules"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_metrics_read" {
  role       = aws_iam_role.lambda_mcp.name
  policy_arn = aws_iam_policy.cloudwatch_metrics_read.arn
}

