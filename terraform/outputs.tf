# Output values
output "postgresql_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.postgresql.name
}

output "postgresql_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.postgresql.arn
}

output "postgresql_service_names" {
  description = "Names of the PostgreSQL ECS services"
  value       = aws_ecs_service.postgresql[*].name
}

output "postgresql_load_balancer_dns" {
  description = "DNS name of the Network Load Balancer"
  value       = aws_lb.postgresql.dns_name
}

output "postgresql_load_balancer_zone_id" {
  description = "Zone ID of the Network Load Balancer"
  value       = aws_lb.postgresql.zone_id
}

output "postgresql_endpoints" {
  description = "PostgreSQL connection endpoints"
  value = [
    for i in range(var.postgresql_instance_count) : {
      host = aws_lb.postgresql.dns_name
      port = var.postgresql_port + i
      name = "postgresql-${i + 1}"
    }
  ]
}

output "postgresql_security_group_id" {
  description = "ID of the PostgreSQL security group"
  value       = aws_security_group.postgresql.id
}

output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.postgresql_data.id
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.postgresql_data.dns_name
}

output "ssm_parameter_names" {
  description = "Names of the SSM parameters"
  value = {
    username = aws_ssm_parameter.postgresql_username.name
    password = aws_ssm_parameter.postgresql_password.name
    database = aws_ssm_parameter.postgresql_database.name
    port     = aws_ssm_parameter.postgresql_port.name
  }
}
