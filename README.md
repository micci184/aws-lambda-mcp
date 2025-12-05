# AWS Lambda MCP Server

AWS Lambda上で動作するMCPサーバー。AWS CLIを実行してCloudWatchのメトリクス・ログを参照できます。

[awslabs/run-model-context-protocol-servers-with-aws-lambda](https://github.com/awslabs/run-model-context-protocol-servers-with-aws-lambda) を使用しています。

## アーキテクチャ

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│ MCP Client  │────▶│ Lambda Function  │────▶│ AWS CLI v2  │
│ (Cursor等)  │     │ URL (認証なし)    │     │             │
└─────────────┘     └──────────────────┘     └─────────────┘
```

## 機能

- **run_aws_cli**: AWS CLIコマンドを実行するMCPツール
- CloudWatch Logs / Metrics の読み取り権限を付与

## デプロイ

### 1. Dockerイメージのビルド & プッシュ

```bash
# 変数設定
AWS_REGION=ap-northeast-1
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO_NAME=lambda-mcp-server

# ECRにログイン
aws ecr get-login-password --region ${AWS_REGION} | \
  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# ビルド & プッシュ
docker build -t ${ECR_REPO_NAME}:latest .
docker tag ${ECR_REPO_NAME}:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest
```

### 2. Terraformでデプロイ

```hcl
module "lambda_mcp" {
  source = "./terraform/modules/lambda_mcp"

  function_name       = "aws-cli-mcp-server"
  ecr_repository_name = "lambda-mcp-server"
  aws_region          = "ap-northeast-1"
  
  # オプション
  timeout     = 300
  memory_size = 512
  
  tags = {
    Environment = "dev"
    Project     = "mcp-server"
  }
}

output "mcp_server_url" {
  value = module.lambda_mcp.function_url
}
```

```bash
terraform init
terraform apply
```

### 3. MCPクライアント設定

Cursor等のMCPクライアントで以下のように設定:

```json
{
  "mcpServers": {
    "aws-cli": {
      "url": "https://xxxxxxxxx.lambda-url.ap-northeast-1.on.aws/"
    }
  }
}
```

## IAM権限

Lambda関数には以下の権限が付与されます：

- **CloudWatch Logs**: ログの読み取り（DescribeLogGroups, GetLogEvents, FilterLogEvents等）
- **CloudWatch Metrics**: メトリクスの読み取り（GetMetricData, ListMetrics, DescribeAlarms等）

追加の権限が必要な場合は、`terraform/modules/lambda_mcp/iam.tf` を編集してください。

## 認証ありの場合

本番環境では、Lambda Function URLにIAM認証を設定することを推奨します。

### 1. Terraformの変更

`main.tf` の `authorization_type` を変更:

```hcl
resource "aws_lambda_function_url" "mcp_server" {
  function_name      = aws_lambda_function.mcp_server.function_name
  authorization_type = "AWS_IAM"  # NONEからAWS_IAMに変更
  # ...
}
```

### 2. IAMポリシーの付与

クライアント側のIAMユーザー/ロールに以下の権限を付与:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunctionUrl",
      "Resource": "arn:aws:lambda:ap-northeast-1:123456789012:function:aws-cli-mcp-server",
      "Condition": {
        "StringEquals": {
          "lambda:FunctionUrlAuthType": "AWS_IAM"
        }
      }
    }
  ]
}
```

### 3. クライアント側の実装

IAM認証ありの場合、MCPクライアントはAWS SigV4署名付きリクエストを送信する必要があります。
`mcp-lambda` パッケージの `aws_iam_streamablehttp_client` を使用:

```python
from mcp import ClientSession
from mcp_lambda import aws_iam_streamablehttp_client

async with aws_iam_streamablehttp_client(
    endpoint="https://xxxxxxxxx.lambda-url.ap-northeast-1.on.aws/",
    aws_service="lambda",
    aws_region="ap-northeast-1",
) as (read_stream, write_stream, _):
    async with ClientSession(read_stream, write_stream) as session:
        await session.initialize()
        result = await session.call_tool("run_aws_cli", {"command": "cloudwatch list-metrics"})
```

## 使用例

MCPクライアントから以下のようなコマンドを実行できます：

```
# CloudWatch Logsのロググループ一覧
aws logs describe-log-groups

# 特定のロググループのログを取得
aws logs filter-log-events --log-group-name /aws/lambda/my-function --limit 10

# CloudWatchメトリクスの取得
aws cloudwatch list-metrics --namespace AWS/Lambda

# アラームの一覧
aws cloudwatch describe-alarms
```

## 注意事項

- Lambda Function URLは認証なし（NONE）で設定されています。本番環境では認証を有効にすることを推奨します。
- AWS CLIコマンドはLambda関数のIAMロール権限の範囲内で実行されます。
- タイムアウトはデフォルト300秒（5分）に設定されています。

## ライセンス

Apache-2.0

