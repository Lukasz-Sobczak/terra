output "lambda_function_name" {
  value = aws_lambda_function.sensor_function.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.sensor_terra.name
}
