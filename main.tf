# main.tf
terraform {
  backend "s3" {
    bucket         = "wiaderkozestanemterra"     # Zmień na nazwę swojego S3 bucket
    key            = "lambda/sensor-terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"          # Zmień jeśli tworzysz inną nazwę tabeli
    encrypt        = true
  }
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "wiaderkozestanemterra"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

provider "aws" {
  region = "us-east-1"
}

# Wstawiamy ARN istniejacej roli IAM na sztywno
locals {
  lambda_role_arn = "arn:aws:iam::708429773842:role/LabRole"
}

resource "aws_sns_topic" "sensor_mail" {
  name = "Sensor_mail"
}

resource "aws_dynamodb_table" "sensor_terra" {
  name         = "SensorTerra"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "sensor_id"

  attribute {
    name = "sensor_id"
    type = "N"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "sensor_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "sensor_temperature_lambda"
  role             = local.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 10
  environment {
    variables = {
      AWS_NODE_ENV = "production"
    }
  }
}
