provider "aws" {
  region = "ap-south-1"  # Change to your preferred region
}

resource "aws_vpc" "medusa_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "medusa_public_subnet" {
  vpc_id     = aws_vpc.medusa_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "medusa_internet_gateway" {
  vpc_id = aws_vpc.medusa_vpc.id
}

resource "aws_security_group" "medusa_ecs_sg" {
  name        = "medusa-ecs-sg"
  description = "Allow inbound traffic for Medusa ECS Fargate"

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.medusa_vpc.id
}

resource "aws_ecs_cluster" "medusa_ecs_cluster" {
  name = "medusa-ecs-cluster"
}

resource "aws_ecs_task_definition" "medusa_task_definition" {
  family                   = "medusa-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "medusa-container"
    image     = "medusajs/medusa:latest"
    essential = true
    portMappings = [{
      containerPort = 9000
      hostPort      = 9000
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "DATABASE_URL"
        value = "your-postgresql-database-url"  # Replace with your DB URL
      },
      {
        name  = "JWT_SECRET"
        value = "your-jwt-secret"  # Replace with your JWT secret
      }
    ]
  }])
}

resource "aws_ecs_service" "medusa_ecs_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_ecs_cluster.id
  task_definition = aws_ecs_task_definition.medusa_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.medusa_public_subnet.id]
    security_groups = [aws_security_group.medusa_ecs_sg.id]
    assign_public_ip = true
  }
}

  
