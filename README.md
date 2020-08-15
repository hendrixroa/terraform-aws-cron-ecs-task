# Cron ECS Task

Module to automate the ecs task creation integrated with cron-jobs triggered by AWS Cloudwatch Events.

- Terraform version:  `0.13.+`

## How to use

```hcl

module "cloudtrail" {
  source = "hendrixroa/cloudtrail/aws"

  enabled = var.aws_profile == "production" ? 1 : 0
  name    = "My awesome app"
}
```
