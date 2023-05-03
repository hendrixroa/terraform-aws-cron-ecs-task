// AWS ECS Task definition to run the container passed by name
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.app}-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  cpu                      = var.cpu_unit
  memory                   = var.memory

  container_definitions = data.template_file.main.rendered
}

data "template_file" "main" {
  template = file("${path.module}/task_definition_${var.use_cloudwatch_logs ? "cloudwatch" : "elasticsearch"}.json")

  vars = {
    ecr_image_url  = var.repo_url
    name           = var.app
    name_index_log = lower(var.app)
    listen_port    = var.listen_port
    region         = var.region
    environment    = jsonencode(concat(local.main_environment, var.environment_list))
    prefix_logs    = var.prefix_logs
    port           = var.listen_port
    es_url         = var.es_url
  }
}

locals {
  main_environment = [
    {
      name  = "APP",
      value = var.app
    }
  ]
}

