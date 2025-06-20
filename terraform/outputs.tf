output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.fishing_chat.name
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "rabbitmq_discovery_service" {
  description = "RabbitMQ service discovery DNS"
  value       = "rabbitmq.fishing-chat.local"
}

output "efs_file_system_id" {
  description = "EFS file system ID for RabbitMQ data"
  value       = aws_efs_file_system.rabbitmq_data.id
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups"
  value = {
    rabbitmq = aws_cloudwatch_log_group.rabbitmq.name
    chat_api = aws_cloudwatch_log_group.chat_api.name
    web      = aws_cloudwatch_log_group.web.name
  }
} 
