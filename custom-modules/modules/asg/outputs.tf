output "security_group" {
  value = aws_security_group.sg_instance.id
  description = "Instance security group"
}
