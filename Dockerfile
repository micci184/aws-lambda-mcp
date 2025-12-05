FROM public.ecr.aws/lambda/python:3.13

ARG MCP_LAMBDA_VERSION=0.5.3
ENV AWS_DEFAULT_REGION=us-east-1

# Install unzip for AWS CLI v2 installation
RUN dnf install -y unzip && dnf clean all && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install mcp-lambda and mcp packages
RUN pip install --no-cache-dir \
    "run-mcp-servers-with-aws-lambda==${MCP_LAMBDA_VERSION}" \
    "awslabs.aws-api-mcp-server"

# Copy handler
COPY handler.py ./handler.py

# Set the CMD to handler
CMD ["handler.handler"]
