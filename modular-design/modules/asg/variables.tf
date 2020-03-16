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

variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default = "ami-0e38b48473ea57778" # Amazon Linux 2 AMI
}

variable "instance_type" {
  description = "type for aws EC2 instance"
  default = "t2.micro"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
}
