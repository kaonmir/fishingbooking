# EFS File System for RabbitMQ data persistence
resource "aws_efs_file_system" "rabbitmq_data" {
  creation_token = "fishing-chat-rabbitmq-data"

  performance_mode = "generalPurpose"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  encrypted = true

  tags = {
    Name        = "fishing-chat-rabbitmq-data"
    Environment = var.environment
  }
}

# EFS Mount Targets (각 가용 영역에 하나씩)
resource "aws_efs_mount_target" "rabbitmq_data" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.rabbitmq_data.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

# EFS Access Point for RabbitMQ
resource "aws_efs_access_point" "rabbitmq" {
  file_system_id = aws_efs_file_system.rabbitmq_data.id

  posix_user {
    gid = 999
    uid = 999
  }

  root_directory {
    path = "/rabbitmq"
    creation_info {
      owner_gid   = 999
      owner_uid   = 999
      permissions = "755"
    }
  }

  tags = {
    Name        = "fishing-chat-rabbitmq-access-point"
    Environment = var.environment
  }
}

# Security Group for EFS
resource "aws_security_group" "efs" {
  name_prefix = "fishing-chat-efs-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.rabbitmq.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "fishing-chat-efs-sg"
    Environment = var.environment
  }
} 
