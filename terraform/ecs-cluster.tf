# ECS Cluster
resource "aws_ecs_cluster" "fishing_chat" {
  name = "fishing-chat-cluster"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "fishing-chat-cluster"
    Environment = var.environment
  }
}

# ECS Cluster Capacity Provider
resource "aws_ecs_cluster_capacity_providers" "fishing_chat" {
  cluster_name = aws_ecs_cluster.fishing_chat.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "rabbitmq" {
  name              = "/ecs/fishing-chat-rabbitmq"
  retention_in_days = 7

  tags = {
    Name        = "fishing-chat-rabbitmq-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "chat_api" {
  name              = "/ecs/fishing-chat-api"
  retention_in_days = 7

  tags = {
    Name        = "fishing-chat-api-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/fishing-chat-web"
  retention_in_days = 7

  tags = {
    Name        = "fishing-chat-web-logs"
    Environment = var.environment
  }
} 
