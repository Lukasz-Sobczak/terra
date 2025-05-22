variable "function_name" {}
variable "lambda_role_arn" {}
variable "source_dir" {}
variable "handler" {}
variable "runtime" {}
variable "secret_arn" {
  type        = string
}