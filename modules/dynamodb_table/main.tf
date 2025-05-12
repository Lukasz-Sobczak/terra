resource "aws_dynamodb_table" "dynamodb_table" {
  name           = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = attr.name
    type = attr.type
  }
}