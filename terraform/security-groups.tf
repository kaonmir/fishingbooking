# Security Group for RabbitMQ
resource "aws_security_group" "rabbitmq" {
  name_prefix = "fishing-chat-rabbitmq-"
  vpc_id      = var.vpc_id

  # AMQP port
  ingress {
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.chat_api.id]
  }

  # Management UI port
  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # RabbitMQ clustering ports
  ingress {
    from_port = 25672
    to_port   = 25672
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 4369
    to_port   = 4369
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "fishing-chat-rabbitmq-sg"
    Environment = var.environment
  }
}

# Security Group for Chat API
resource "aws_security_group" "chat_api" {
  name_prefix = "fishing-chat-api-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id, aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "fishing-chat-api-sg"
    Environment = var.environment
  }
}

# Security Group for Web
resource "aws_security_group" "web" {
  name_prefix = "fishing-chat-web-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "fishing-chat-web-sg"
    Environment = var.environment
  }
}

# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "fishing-chat-alb-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "fishing-chat-alb-sg"
    Environment = var.environment
  }
} 
