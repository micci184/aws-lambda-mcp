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

## Security

> ⚠️ **Warning**: This deployment uses Lambda Function URL with `authorization_type = "NONE"`, meaning the endpoint is publicly accessible. For production use, consider enabling IAM authentication or adding other security measures.

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

## Test with curl

```bash
FUNCTION_URL=$(terraform output -raw function_url)

# Initialize
curl -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {
        "name": "test-client",
        "version": "1.0.0"
      }
    }
  }'

# List available tools
curl -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}'
```

## License

Apache-2.0
