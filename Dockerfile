FROM public.ecr.aws/lambda/python:3.12

# Package versions
ARG MCP_LAMBDA_VERSION=0.5.3

# Install unzip for AWS CLI v2 installation
RUN dnf install -y unzip && dnf clean all

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install mcp-lambda and awslabs-aws-api-mcp-server
RUN pip install --no-cache-dir \
    "mcp-lambda==${MCP_LAMBDA_VERSION}" \
    "awslabs-aws-api-mcp-server"

# Copy handler
COPY handler.py ${LAMBDA_TASK_ROOT}/

# Set the CMD to handler
CMD ["handler.handler"]
