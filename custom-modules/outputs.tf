output "alb_dns_name" {
  value       = module.alb.dns_name
  description = "Load balancer DNS name"
}
