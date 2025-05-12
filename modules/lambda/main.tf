resource "aws_lambda_function" "sensor_function" {
  filename         = var.lambda_zip
  function_name    = var.function_name
  role             = var.lambda_role_arn
  handler          = var.handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 10
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/lambda"
  output_path = "${path.module}/lambda.zip"
}


output "lambda_function_name" {
  value = aws_lambda_function.sensor_function.function_name
}


