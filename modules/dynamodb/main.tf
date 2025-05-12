resource "aws_dynamodb_table" "sensor_terra" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "sensor_id"

  attribute {
    name = "sensor_id"
    type = "N"
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.sensor_terra.name
}