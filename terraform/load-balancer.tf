# Network Load Balancer for PostgreSQL (internal)
resource "aws_lb" "postgresql" {
  name               = "${var.project_name}-${var.environment}-postgresql-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = local.target_subnets

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-nlb"
  }
}

# Target group for PostgreSQL
resource "aws_lb_target_group" "postgresql" {
  count = var.postgresql_instance_count

  name        = "${var.project_name}-${var.environment}-pg-${count.index + 1}"
  port        = var.postgresql_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = null
    path                = null
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 10
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-tg-${count.index + 1}"
  }
}

# Listeners for each PostgreSQL instance
resource "aws_lb_listener" "postgresql" {
  count = var.postgresql_instance_count

  load_balancer_arn = aws_lb.postgresql.arn
  port              = var.postgresql_port + count.index # 5432, 5433, 5434
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.postgresql[count.index].arn
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-listener-${count.index + 1}"
  }
} 
