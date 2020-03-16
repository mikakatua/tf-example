output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.priv_subnets[*].id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.pub_subnets[*].id
}
