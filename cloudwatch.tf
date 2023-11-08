resource "aws_cloudwatch_log_group" "aplicacao" {
  name              = "/ecs/cluster-nest-fiap/task-nest-fiap"
  retention_in_days = 3
}
