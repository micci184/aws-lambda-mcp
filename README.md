# AWS Lambda MCP Server

MCP server running on AWS Lambda using [awslabs/mcp-lambda](https://github.com/awslabs/run-model-context-protocol-servers-with-aws-lambda).

## Requirements

- Terraform >= 1.14
- Docker
- AWS CLI

## Deploy

> **Note**: Lambda requires an ECR image to exist before creation. This creates a chicken-and-egg problem:
>
> - ECR repository must be created first via Terraform
> - Docker image must be pushed before Lambda can be created
> - Therefore, initial deployment requires multiple steps (subsequent updates only need `terraform apply`)

### 1. Create ECR Repository

```bash
cd terraform
terraform init
terraform apply -target=module.lambda_mcp.aws_ecr_repository.lambda_mcp
```

### 2. Build & Push Docker Image

```bash
ECR_REPO=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password | docker login --username AWS --password-stdin ${ECR_REPO%/*}
docker build -t mcp-server ..
docker tag mcp-server ${ECR_REPO}:latest
docker push ${ECR_REPO}:latest
```

### 3. Deploy Lambda

```bash
terraform apply
```

### Subsequent Updates

After initial deployment, just push a new image and run `terraform apply`:

```bash
docker build -t mcp-server ..
docker tag mcp-server ${ECR_REPO}:latest
docker push ${ECR_REPO}:latest
terraform apply
```

## MCP Client Config

```json
{
  "mcpServers": {
    "aws-api": {
      "url": "<terraform output function_url>"
    }
  }
}
```

## License

Apache-2.0
