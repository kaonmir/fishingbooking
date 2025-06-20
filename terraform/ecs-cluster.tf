# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "postgresql" {
  count = var.enable_logging ? 1 : 0

  name              = "/ecs/${var.project_name}-${var.environment}-postgresql"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-logs"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "postgresql" {
  name = "${var.project_name}-${var.environment}-postgresql"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = var.enable_logging ? aws_cloudwatch_log_group.postgresql[0].name : null
      }
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql"
  }
}

# Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "postgresql" {
  cluster_name = aws_ecs_cluster.postgresql.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
} 
