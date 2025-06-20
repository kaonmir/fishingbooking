# Task definition for PostgreSQL
resource "aws_ecs_task_definition" "postgresql" {
  count = var.postgresql_instance_count

  family                   = "${var.project_name}-${var.environment}-postgresql-${count.index + 1}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.postgresql_cpu
  memory                   = var.postgresql_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "postgresql"
      image = var.postgresql_image

      essential = true

      portMappings = [
        {
          containerPort = var.postgresql_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "POSTGRES_DB"
          value = var.postgresql_database
        },
        {
          name  = "PGDATA"
          value = "/var/lib/postgresql/data/instance-${count.index + 1}"
        }
      ]

      secrets = [
        {
          name      = "POSTGRES_USER"
          valueFrom = aws_ssm_parameter.postgresql_username.arn
        },
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = aws_ssm_parameter.postgresql_password.arn
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "postgresql-data"
          containerPath = "/var/lib/postgresql/data"
        }
      ]

      logConfiguration = var.enable_logging ? {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.postgresql[0].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "postgresql-${count.index + 1}"
        }
      } : null

      healthCheck = {
        command = [
          "CMD-SHELL",
          "pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  volume {
    name = "postgresql-data"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.postgresql_data.id
      root_directory = "/"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-${count.index + 1}"
  }
}

# ECS Service for each PostgreSQL instance
resource "aws_ecs_service" "postgresql" {
  count = var.postgresql_instance_count

  name            = "${var.project_name}-${var.environment}-postgresql-${count.index + 1}"
  cluster         = aws_ecs_cluster.postgresql.id
  task_definition = aws_ecs_task_definition.postgresql[count.index].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = local.target_subnets
    security_groups  = [aws_security_group.postgresql.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.postgresql[count.index].arn
    container_name   = "postgresql"
    container_port   = var.postgresql_port
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  enable_execute_command = false

  depends_on = [aws_efs_mount_target.postgresql_data]

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-${count.index + 1}"
  }
}
