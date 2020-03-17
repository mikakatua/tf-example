output "dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

output "target_group" {
  value = aws_lb_target_group.tg_asg.arn
  description = "ALB target group resource"
}
