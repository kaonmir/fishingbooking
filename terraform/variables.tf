variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fishing-booking"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "postgresql_image" {
  description = "PostgreSQL Docker image"
  type        = string
  default     = "postgres:15"
}

variable "postgresql_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "postgres"
}

variable "postgresql_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "postgresql_database" {
  description = "PostgreSQL database name"
  type        = string
  default     = "fishing_booking"
}

variable "postgresql_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "postgresql_instance_count" {
  description = "Number of PostgreSQL instances to deploy"
  type        = number
  default     = 3
}

variable "postgresql_cpu" {
  description = "CPU units for PostgreSQL containers (1024 = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "postgresql_memory" {
  description = "Memory for PostgreSQL containers in MB"
  type        = number
  default     = 2048
}

variable "enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
} 
