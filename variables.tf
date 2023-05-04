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
  default = null
}

variable "repo_url" {
  description = "ECR repository url to execute tasks"
}

variable "region" {
  description = "AWS region of task module"
  default     = "us-east-1"
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

variable "es_url" {
  description = "Elasticsearch URL"
  default = "disabled"
}

variable "prefix_logs" {
  default = "ecs"
}

variable "use_cloudwatch_logs" {
  default = false
}

variable "environment_list" {
  description = "Environment variables in map-list format. eg: [{ name='foo', value='bar' }]"
}

variable "public_ip" {
  default = true
}
