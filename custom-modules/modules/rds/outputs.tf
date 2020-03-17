output "database_host" {
  value       = aws_db_instance.example.address
  description = "Hostname of the RDS instance"
}

output "database_port" {
  value       = aws_db_instance.example.port
  description = "Database port"
}

output "database_name" {
  value       = aws_db_instance.example.name
  description = "Database name"
}

output "database_user" {
  value       = aws_db_instance.example.username
  description = "Master username for the database"
}

output "database_pass" {
  value       = var.database_pass
  description = "Database master password"
}
