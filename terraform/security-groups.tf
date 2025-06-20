# Security group for PostgreSQL ECS tasks
resource "aws_security_group" "postgresql" {
  name_prefix = "${var.project_name}-${var.environment}-postgresql-"
  description = "Security group for PostgreSQL ECS tasks"
  vpc_id      = var.vpc_id

  # Allow PostgreSQL traffic from within VPC
  ingress {
    description = "PostgreSQL from VPC"
    from_port   = var.postgresql_port
    to_port     = var.postgresql_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.existing.cidr_block]
  }

  # Allow PostgreSQL traffic between instances (for replication if needed)
  ingress {
    description = "PostgreSQL from self"
    from_port   = var.postgresql_port
    to_port     = var.postgresql_port
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for EFS mount targets
resource "aws_security_group" "efs" {
  name_prefix = "${var.project_name}-${var.environment}-efs-"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from PostgreSQL tasks"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.postgresql.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-efs-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
} 
