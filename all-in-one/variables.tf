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
  default     = 8080
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "cidr_private_subnets" {
  description = "CIDR block for the private subnets"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cidr_public_subnets" {
  description = "CIDR block for the public subnets"
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "create_nat_gateway" {
  description = "Create the NAT Gateway resouces"
  type = bool
  default = false
}
