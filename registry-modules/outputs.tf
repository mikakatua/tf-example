output "alb_dns_name" {
  value       = module.alb.this_lb_dns_name
  description = "Load balancer DNS name"
}
