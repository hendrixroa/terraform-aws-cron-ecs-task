// Event target to linking the cron task and the cron job
resource "aws_cloudwatch_event_target" "main" {
  target_id = "${lower(var.app)}-target"
  arn       = var.ecs_cluster
  rule      = var.event_rule
  role_arn  = var.ecs_event_role

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.main.arn
    launch_type         = "FARGATE"
    platform_version    = "LATEST"

    network_configuration {
      security_groups  = var.security_groups
      subnets          = var.subnets
      assign_public_ip = var.public_ip
    }
  }

  depends_on = [
    aws_ecs_task_definition.main
  ]
}