// Auxiliary logs
resource "aws_cloudwatch_log_group" "main" {
  count             = var.use_cloudwatch_logs ? 0 : 1
  name              = "${var.app}-firelens-container"
  retention_in_days = 14
}

// Main app logs
resource "aws_cloudwatch_log_group" "main_app" {
  count             = var.use_cloudwatch_logs ? 1 : 0
  name              = var.app
  retention_in_days = 14
}