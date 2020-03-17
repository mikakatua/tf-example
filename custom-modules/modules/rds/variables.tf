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

variable "database_name" {
   description = "Name of the database to create when the DB instance is created"
   type        = string
}

variable "database_user" {
   description = "Username for the master DB user"
   type        = string
}

variable "database_pass" {
  description = "Password for the master DB user"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs assigned to the DB instance"
  type        = list(string)
}

variable "client_sg_id" {
  description = "The security group id to allow access from"
  type        = string
}
