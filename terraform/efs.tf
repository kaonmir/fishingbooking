# EFS file system for PostgreSQL data persistence
resource "aws_efs_file_system" "postgresql_data" {
  creation_token = "${var.project_name}-${var.environment}-postgresql-data"

  performance_mode                = "generalPurpose"
  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = 10

  encrypted = true

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-data"
  }

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

# EFS mount targets - one for each available subnet
resource "aws_efs_mount_target" "postgresql_data" {
  count = length(local.target_subnets)

  file_system_id  = aws_efs_file_system.postgresql_data.id
  subnet_id       = local.target_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

# Local value to determine which subnets to use
locals {
  # Use private subnets if available, otherwise use all subnets
  target_subnets = length(data.aws_subnets.private.ids) > 0 ? data.aws_subnets.private.ids : data.aws_subnets.all.ids
} 
