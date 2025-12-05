module "lambda_mcp" {
  source = "./modules/lambda_mcp"

  function_name       = var.function_name
  ecr_repository_name = var.ecr_repository_name
  aws_region          = var.aws_region
  image_tag           = var.image_tag
  timeout             = var.timeout
  memory_size         = var.memory_size
  tags                = var.tags
}

