resource "aws_lambda_function" "sensor_function" {
  filename         = var.lambda_zip
  function_name    = var.function_name
  role             = var.lambda_role_arn
  handler          = var.handler
  source_code_hash = filebase64sha256(var.lambda_zip)
  runtime          = "python3.12"
  timeout          = 10
}

output "lambda_function_name" {
  value = aws_lambda_function.sensor_function.function_name
}


