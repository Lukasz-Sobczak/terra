variable "lambda_zip" {
  type        = string
  description = "Path to the lambda deployment zip"
}

variable "function_name" {
  type        = string
  description = "The name of the Lambda function"
}

variable "lambda_role_arn" {
  type        = string
  description = "The ARN of the Lambda execution role"
}

variable "handler" {
  type        = string
  description = "The handler of the Lambda function"
  default     = "lambda_function.lambda_handler"
}
