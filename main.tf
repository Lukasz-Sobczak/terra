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

module "sns" {
  source = "./modules/sns"
  sns_name = "Sensor_mail"
}

module "dynamodb" {
  source = "./modules/dynamodb"
  table_name = "SensorStatus"
}

module "lambda" {
  source = "./modules/lambda"
  lambda_zip  = "${path.module}/lambda.zip"
  function_name = "sensor_temperature_lambda"
  lambda_role_arn = "arn:aws:iam::708429773842:role/LabRole"
  handler = "lambda_function.lambda_handler"
}

output "sns_topic_arn" {
  value = module.sns.sns_topic_arn
}

output "dynamodb_table_name" {
  value = module.dynamodb.dynamodb_table_name
}

output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}
