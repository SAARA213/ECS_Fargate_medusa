output "ecs_service_arn" {
  value = aws_ecs_service.medusa_service.id
}
