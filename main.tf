provider "aws" {
  region = "us-east-1"
}
/*
terraform {
  backend "s3" {
    bucket         = "wiaderkozestanemterra"
    key            = "lambda/sensor-terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
*/
locals {
  lambda_role_arn = "arn:aws:iam::708429773842:role/LabRole"
}

resource "aws_secretsmanager_secret" "db_password" {
  name        = "db_password"
  description = "Hasło do bazy danych "
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "admin"
    password = "SuperTajneHaslo123!"
  })
}


module "sns_topic" {
  source = "./modules/sns_topic"
  topic_name = "Sensor_mail"
}

module "sensor_table" {
  source = "./modules/sensor_table"
  table_name = "SensorTerra_v2"
}

module "lambda_function" {
  source           = "./modules/lambda_function"
  function_name    = "sensor_temperature_lambda_v3"
  lambda_role_arn  = local.lambda_role_arn
  source_dir       = "${path.module}/lambda"
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  secret_arn = aws_secretsmanager_secret.db_password.arn
}
