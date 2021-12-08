resource "aws_cloudwatch_log_group" "example" {
  name              = "/ecs/example"
  retention_in_days = 60
}
