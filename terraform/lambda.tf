
# Define the VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Define subnets
resource "aws_subnet" "my_subnet" {
  count = 2
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block  = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet-${count.index}"
  }
}

# Define a security group
resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-sg"
  }
}

# Define IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "my-node-app-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWSLambdaBasicExecutionRole policy for CloudWatch logging
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach AWSLambdaVPCAccessExecutionRole policy for VPC access
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# IAM Role Policy for DynamoDB access
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Resource = "*"
      }
    ]
  })
}

# Define Lambda function using ECR Image
resource "aws_lambda_function" "app" {
  function_name = "my-node-app"
  package_type  = "Image"
  image_uri     = var.image_uri
  role          = aws_iam_role.lambda_role.arn

  vpc_config {
    subnet_ids          = aws_subnet.my_subnet[*].id
    security_group_ids  = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      # Add any environment variables here
    }
  }
}

# Define VPC Endpoint for DynamoDB
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id = aws_vpc.my_vpc.id

  service_name = "com.amazonaws.${var.region}.dynamodb"

  route_table_ids = [aws_vpc.my_vpc.main_route_table_id]  # Corrected
}

# Define API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "my-node-app-api"
  description = "API Gateway for my-node-app"
}

# Define API Gateway Resources and Methods
resource "aws_api_gateway_resource" "users_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.users_resource.id
  path_part   = "users"
}

resource "aws_api_gateway_method" "get_users" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_users" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_resource" "user_by_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "get_user_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.user_by_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "put_user_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.user_by_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "delete_user_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.user_by_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# Define API Gateway Integrations with Lambda
resource "aws_api_gateway_integration" "lambda_get_users" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.get_users.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.app.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_post_users" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.post_users.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.app.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_get_user_by_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_by_id.id
  http_method = aws_api_gateway_method.get_user_by_id.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.app.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_put_user_by_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_by_id.id
  http_method = aws_api_gateway_method.put_user_by_id.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.app.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_delete_user_by_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_by_id.id
  http_method = aws_api_gateway_method.delete_user_by_id.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.app.invoke_arn
}

# Define API Gateway Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
  
  depends_on = [
    aws_api_gateway_integration.lambda_get_users,
    aws_api_gateway_integration.lambda_post_users,
    aws_api_gateway_integration.lambda_get_user_by_id,
    aws_api_gateway_integration.lambda_put_user_by_id,
    aws_api_gateway_integration.lambda_delete_user_by_id
  ]
}

# Allow API Gateway to invoke Lambda function
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Output API URL
output "api_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}

# Data source for availability zones
data "aws_availability_zones" "available" {}
