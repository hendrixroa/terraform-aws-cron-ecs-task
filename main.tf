// AWS ECS Task defintion to run the container passed by name
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.app}-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  cpu                      = var.cpu_unit
  memory                   = var.memory

  container_definitions = data.template_file.main.rendered

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "main" {
  template = file("${path.module}/task_definition_${var.use_cloudwatch_logs ? "cloudwatch" : "elasticsearch"}.json")

  vars = {
    ecr_image_url    = var.repo_url
    name             = var.app
    name_index_log   = lower(var.app)
    listen_port      = var.listen_port
    region           = var.region
    secrets_name      = var.secret_name
    secrets_value_arn = var.secret_value_arn
    prefix_logs      = var.prefix_logs
    port             = var.listen_port
  }
}

// Auxiliary logs
resource "aws_cloudwatch_log_group" "main" {
  count             = var.use_cloudwatch_logs ? 0 : 1
  name              = "${var.app}-firelens-container"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "main_app" {
  count             = var.use_cloudwatch_logs ? 1 : 0
  name              = var.app
  retention_in_days = 14
}

// Event target to linking the cron task and the cron job
resource "aws_cloudwatch_event_target" "main" {
  count     = var.disable_event_rule == true ? 0 : 1
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
      assign_public_ip = false
    }
  }

  depends_on = [
    aws_ecs_task_definition.main
  ]
}
