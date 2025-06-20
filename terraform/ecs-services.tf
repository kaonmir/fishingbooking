# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "fishing_chat" {
  name        = "fishing-chat.local"
  description = "Private DNS namespace for fishing chat services"
  vpc         = var.vpc_id

  tags = {
    Name        = "fishing-chat-namespace"
    Environment = var.environment
  }
}

resource "aws_service_discovery_service" "rabbitmq" {
  name = "rabbitmq"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.fishing_chat.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_grace_period_seconds = 60

  tags = {
    Name        = "fishing-chat-rabbitmq-discovery"
    Environment = var.environment
  }
}

# RabbitMQ Task Definition
resource "aws_ecs_task_definition" "rabbitmq" {
  family                   = "fishing-chat-rabbitmq"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "rabbitmq"
      image     = "rabbitmq:3.12-management"
      essential = true

      portMappings = [
        {
          containerPort = 5672
          protocol      = "tcp"
          name          = "amqp"
        },
        {
          containerPort = 15672
          protocol      = "tcp"
          name          = "management"
        },
        {
          containerPort = 25672
          protocol      = "tcp"
          name          = "clustering"
        },
        {
          containerPort = 4369
          protocol      = "tcp"
          name          = "epmd"
        }
      ]

      environment = [
        {
          name  = "RABBITMQ_DEFAULT_USER"
          value = "admin"
        },
        {
          name  = "RABBITMQ_ERLANG_COOKIE"
          value = "FISHING_CHAT_UNIQUE_COOKIE_12345"
        },
        {
          name  = "RABBITMQ_USE_LONGNAME"
          value = "true"
        }
      ]

      secrets = [
        {
          name      = "RABBITMQ_DEFAULT_PASS"
          valueFrom = aws_ssm_parameter.rabbitmq_password.arn
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "rabbitmq-data"
          containerPath = "/var/lib/rabbitmq"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.rabbitmq.name
          "awslogs-region"        = "ap-northeast-2"
          "awslogs-stream-prefix" = "rabbitmq"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "rabbitmq-diagnostics ping"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  volume {
    name = "rabbitmq-data"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.rabbitmq_data.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.rabbitmq.id
      }
    }
  }

  tags = {
    Name        = "fishing-chat-rabbitmq-task"
    Environment = var.environment
  }
}

# RabbitMQ ECS Service
resource "aws_ecs_service" "rabbitmq" {
  name            = "fishing-chat-rabbitmq"
  cluster         = aws_ecs_cluster.fishing_chat.id
  task_definition = aws_ecs_task_definition.rabbitmq.arn
  desired_count   = 3 # RabbitMQ 클러스터를 위한 3개 인스턴스
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.rabbitmq.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.rabbitmq.arn
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 50
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]

  tags = {
    Name        = "fishing-chat-rabbitmq-service"
    Environment = var.environment
  }
}

# Chat API Task Definition
resource "aws_ecs_task_definition" "chat_api" {
  family                   = "fishing-chat-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "chat-api"
      image     = "859727769026.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-chat-api:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = "ecs"
        },
        {
          name  = "RABBITMQ_HOST"
          value = "rabbitmq.fishing-chat.local"
        },
        {
          name  = "RABBITMQ_PORT"
          value = "5672"
        },
        {
          name  = "RABBITMQ_USER"
          value = "admin"
        }
      ]

      secrets = [
        {
          name      = "DB_HOST"
          valueFrom = aws_ssm_parameter.db_host.arn
        },
        {
          name      = "DB_NAME"
          valueFrom = aws_ssm_parameter.db_name.arn
        },
        {
          name      = "DB_USER"
          valueFrom = aws_ssm_parameter.db_user.arn
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_ssm_parameter.db_password.arn
        },
        {
          name      = "RABBITMQ_PASSWORD"
          valueFrom = aws_ssm_parameter.rabbitmq_password.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.chat_api.name
          "awslogs-region"        = "ap-northeast-2"
          "awslogs-stream-prefix" = "chat-api"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name        = "fishing-chat-api-task"
    Environment = var.environment
  }
}

# Chat API ECS Service
resource "aws_ecs_service" "chat_api" {
  name            = "fishing-chat-api"
  cluster         = aws_ecs_cluster.fishing_chat.id
  task_definition = aws_ecs_task_definition.chat_api.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.chat_api.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.chat_api.arn
    container_name   = "chat-api"
    container_port   = 8080
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 50
  }

  depends_on = [
    aws_lb_listener.main,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
    aws_ecs_service.rabbitmq
  ]

  tags = {
    Name        = "fishing-chat-api-service"
    Environment = var.environment
  }
}

# Web Task Definition
resource "aws_ecs_task_definition" "web" {
  family                   = "fishing-chat-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "859727769026.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-web:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NEXT_PUBLIC_API_URL"
          value = "https://${aws_lb.main.dns_name}/api"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.web.name
          "awslogs-region"        = "ap-northeast-2"
          "awslogs-stream-prefix" = "web"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:80 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }
    }
  ])

  tags = {
    Name        = "fishing-chat-web-task"
    Environment = var.environment
  }
}

# Web ECS Service
resource "aws_ecs_service" "web" {
  name            = "fishing-chat-web"
  cluster         = aws_ecs_cluster.fishing_chat.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.web.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "web"
    container_port   = 80
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 50
  }

  depends_on = [
    aws_lb_listener.main,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy
  ]

  tags = {
    Name        = "fishing-chat-web-service"
    Environment = var.environment
  }
}
