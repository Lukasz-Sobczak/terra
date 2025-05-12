# main.tf
terraform {
  backend "s3" {
    bucket  = "wiaderkozestanemterra" # Zmień na nazwę swojego S3 bucket
    key     = "lambda/sensor-terraform.tfstate"
    region  = "us-east-1"
    dynamodb_table = "terraform-lock-table"    # Zmień jeśli tworzysz inną nazwę tabeli
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Moduł dla S3 bucket na state
module "terraform_state_bucket" {
  source = "./modules/s3_bucket"
  bucket_name = "wiaderkozestanemterra" # Zmienna nazwa bucketu
}

# Moduł dla DynamoDB table do blokowania
module "terraform_lock_table" {
  source = "./modules/dynamodb_table"
  table_name = "terraform-lock-table"
  hash_key   = "LockID"
  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}

# Moduł dla SNS Topic
module "sns_topic" {
  source = "./modules/sns_topic"
  topic_name = "Sensor_mail"
}

# Moduł dla DynamoDB Table na dane sensorów
module "sensor_data_table" {
  source = "./modules/dynamodb_table"
  table_name = "SensorTerra"
  hash_key   = "sensor_id"
  attributes = [
    {
      name = "sensor_id"
      type = "N"
    }
  ]
}

# Moduł dla Lambda Function
module "sensor_lambda_function" {
  source = "./modules/lambda_function"
  function_name = "sensor_temperature_lambda"
  lambda_role_arn = "arn:aws:iam::708429773842:role/LabRole" # Użyj zmiennej
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 10
  source_dir    = "${path.module}/lambda" # Ścieżka do kodu lambdy
}

# Wstawiamy ARN istniejacej roli IAM na sztywno
locals {
  lambda_role_arn = "arn:aws:iam::708429773842:role/LabRole"
}