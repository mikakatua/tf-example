variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch resources in"
  type        = list(string)
}

variable "alb_tg_arns" {
  description = "List of target group ARNs for use with ALB"
  type        = list(string)
}

variable "public_key_path" {
  description = "Public key path"
  default = "~/.ssh/id_rsa.pub"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
}

variable "database_host" {
  description = "Hostname of the RDS instance"
  type        = string
}

variable "database_port" {
  description = "Database port"
  type        = string
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "database_user" {
  description = "Master username for the database"
  type        = string
}

variable "database_pass" {
  description = "Database master password"
  type        = string
}
