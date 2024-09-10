# constant settings
locals {
  image_name    = "my-node-app"
  image_version = "latest"

  lambda_function_name = "my-node-app"

  api_name = "my-node-app-api"
}

variable "stage" {
  description = "The name of the DynamoDB table for student records"
  type        = string
  default     = "dev"
}

variable "student_table_name" {
  description = "The name of the DynamoDB table for student records"
  type        = string
  default     = "student_table"
}

variable "region" {
  type        = string
  default     = "ap-northeast-1"
}
variable "image_uri" {
  description = "The URI of the ECR image for the Lambda function"
  type        = string
}
