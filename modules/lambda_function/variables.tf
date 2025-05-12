variable "function_name" {
  description = "Nazwa funkcji Lambda"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN roli IAM dla Lambda"
  type        = string
}

variable "handler" {
  description = "Handler funkcji Lambda"
  type        = string
}

variable "runtime" {
  description = "Runtime funkcji Lambda"
  type        = string
}

variable "timeout" {
  description = "Timeout funkcji Lambda"
  type        = number
}

variable "source_dir" {
  description = "Ścieżka do katalogu ze źródłem Lambdy"
  type = string
}