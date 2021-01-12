// AWS ECS Task defintion to run the container passed by name
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.app}-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  cpu                      = var.cpu_unit
  memory                   = var.memory

  container_definitions = <<TASK_DEFINITION
[
  {
    "essential": true,
    "image": "906394416424.dkr.ecr.us-east-1.amazonaws.com/aws-for-fluent-bit:latest",
    "name": "log_router",
    "firelensConfiguration": {
      "type": "fluentbit",
      "options": {
        "config-file-type": "file",
        "config-file-value": "/fluent-bit/configs/parse-json.conf"
      }
    },
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${var.app}-firelens-container",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "firelens"
      }
    },
    "memoryReservation": 50
  },
  {
    "essential": true,
    "image": "${var.repo_url}",
    "name": "${var.app}",
    "portMappings": [
      {
        "containerPort": ${var.listen_port},
        "hostPort": ${var.listen_port}
      }
    ],
    "logConfiguration": {
      "logDriver":"awsfirelens",
      "options": {
        "Name": "es",
        "Host": "${var.es_url}",
        "Port": "443",
        "Index": "${lower(var.app)}",
        "Type": "${lower(var.app)}_type",
        "Aws_Auth": "On",
        "Aws_Region": "${var.region}",
        "tls": "On"
      }
    },
    "secrets": [
      {
        "name": "${var.secret_name}",
        "valueFrom": "${var.secret_value_arn}"
      }
    ],
    "environment": [
      {
        "name": "APP",
        "value": "${var.app}"
      },
      {
        "name": "NEW_RELIC_APP_NAME",
        "value": "${var.app}"
      }
    ]
  }
]
TASK_DEFINITION

  lifecycle {
    create_before_destroy = true
  }
}

// Auxiliary logs
resource "aws_cloudwatch_log_group" "main" {
  name              = "${var.app}-firelens-container"
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
