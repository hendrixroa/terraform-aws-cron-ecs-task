variable "app" {
  description = "ECS Task name"
}

variable "cpu_unit" {
  description = "Number of cpu units for container"
  default     = 256
}

variable "memory" {
  description = "Number of memory for container"
  default     = 512
}

variable "listen_port" {
  description = "Port health check for cron task"
  default     = 5004
}

variable "execution_role_arn" {
  description = "IAM Role for execution task"
}

variable "task_role_arn" {
  description = "IAM Role for ECS Tasks"
}

variable "repo_url" {
  description = "ECR repository url to execute tasks"
}

variable "region" {
  description = "AWS region of task module"
  default     = "us-east-1"
}

variable "secret_name" {
  description = "Secret name"
}

variable "secret_value_arn" {
  description = "ARN of secret used for ECS Task"
}

variable "cwl_endpoint" {
  type        = string
  default     = "logs.us-east-1.amazonaws.com"
  description = "Cloudwatch endpoint logs"
}

variable "ecs_cluster" {
  description = "ECS Cluster where the task will be ran"
}

variable "ecs_event_role" {
  description = "Iam role for ecs event"
}

variable "event_rule" {
  description = "Event Rule cron-like to schedule the next executions"
  default     = ""
}

variable "security_groups" {
  description = "Security groups of ecs task execution"
  default     = []
}

variable "subnets" {
  description = "VPC Subnets"
  default     = []
}

variable "disable_event_rule" {
  description = "Disable event rule for non-schedule scripts"
  default     = false
}

variable "lambda_stream_arn" {}

