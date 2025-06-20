# SSM Parameters for secure configuration
resource "aws_ssm_parameter" "rabbitmq_password" {
  name  = "/fishing-chat/rabbitmq/password"
  type  = "SecureString"
  value = var.rabbitmq_password

  tags = {
    Name        = "fishing-chat-rabbitmq-password"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/fishing-chat/database/host"
  type  = "String"
  value = var.db_host

  tags = {
    Name        = "fishing-chat-db-host"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/fishing-chat/database/name"
  type  = "String"
  value = var.db_name

  tags = {
    Name        = "fishing-chat-db-name"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_user" {
  name  = "/fishing-chat/database/user"
  type  = "String"
  value = var.db_user

  tags = {
    Name        = "fishing-chat-db-user"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/fishing-chat/database/password"
  type  = "SecureString"
  value = var.db_password

  tags = {
    Name        = "fishing-chat-db-password"
    Environment = var.environment
  }
} 
