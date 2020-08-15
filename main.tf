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
  template = file("${path.module}/task_definition.json")

  vars = {
    repo_url         = var.repo_url
    app              = var.app
    listen_port      = var.listen_port
    region           = var.region
    secret_name      = var.secret_name
    secret_value_arn = var.secret_value_arn
  }
}

// AWS Cloudwatch log group cron task
resource "aws_cloudwatch_log_group" "main" {
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

// Allow lambda permission to streaming logs of cron-task
resource "aws_lambda_permission" "main" {
  statement_id  = "${var.app}_cloudwatch_allow"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_stream_arn
  principal     = var.cwl_endpoint
  source_arn    = "${aws_cloudwatch_log_group.main.arn}:*"
}

// Add subscription resource to streaming logs of cron-task to Elasticsearch
resource "aws_cloudwatch_log_subscription_filter" "main" {
  name            = "${var.app}_cloudwatch_logs_to_elasticsearch"
  log_group_name  = aws_cloudwatch_log_group.main.name
  filter_pattern  = ""
  destination_arn = var.lambda_stream_arn
  distribution    = "Random"

  depends_on = [aws_lambda_permission.main]
}
