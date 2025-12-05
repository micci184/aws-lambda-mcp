import os, sys
from mcp.client.stdio import StdioServerParameters
from mcp_lambda import ( 
    LambdaFunctionURLEventHandler, 
    StdioServerAdapterRequestHandler
)
# Setup Lambda handler for Function URL
server_params = StdioServerParameters(
    command=sys.executable,
    args=[
        "-m",
        "awslabs.aws_api_mcp_server.server"
    ],
    env=dict(os.environ)
)

request_handler = LambdaFunctionURLEventHandler(
    StdioServerAdapterRequestHandler(server_params),
)

def handler(event, context):
    return request_handler.handle(event, context)
