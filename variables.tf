variable "sns_topic_arn" {
  description = "SNS topic ARN to publish critical alerts"
  type        = string
  default     = "arn:aws:sns:us-east-1:708429773842:Sensor_mail"
}
