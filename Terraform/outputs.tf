# Output the load balancer DNS name
output "load_balancer_dns" {
    value = aws_lb.medusa_alb.dns_name
}
