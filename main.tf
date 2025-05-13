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
}
