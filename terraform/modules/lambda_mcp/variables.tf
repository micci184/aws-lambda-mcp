variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "aws_region" {
  description = "AWS region for the Lambda function"
  type        = string
  default     = "us-east-1"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 300
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}

variable "environment_variables" {
  description = "Additional environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "cors_allow_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

