# SSM parameter for PostgreSQL password
resource "aws_ssm_parameter" "postgresql_password" {
  name  = "/${var.project_name}/${var.environment}/postgresql/password"
  type  = "SecureString"
  value = var.postgresql_password

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-password"
  }
}

# SSM parameter for PostgreSQL username
resource "aws_ssm_parameter" "postgresql_username" {
  name  = "/${var.project_name}/${var.environment}/postgresql/username"
  type  = "String"
  value = var.postgresql_username

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-username"
  }
}

# SSM parameter for PostgreSQL database name
resource "aws_ssm_parameter" "postgresql_database" {
  name  = "/${var.project_name}/${var.environment}/postgresql/database"
  type  = "String"
  value = var.postgresql_database

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-database"
  }
}

# SSM parameter for PostgreSQL port
resource "aws_ssm_parameter" "postgresql_port" {
  name  = "/${var.project_name}/${var.environment}/postgresql/port"
  type  = "String"
  value = tostring(var.postgresql_port)

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-port"
  }
} 
