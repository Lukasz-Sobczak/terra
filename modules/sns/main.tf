resource "aws_sns_topic" "sensor_mail" {
  name = var.sns_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.sensor_mail.arn
}
