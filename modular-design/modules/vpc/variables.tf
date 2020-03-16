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

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cidr_private_subnets" {
  description = "CIDR block for the private subnets"
  type        = list(string)
  default     = []
}

variable "cidr_public_subnets" {
  description = "CIDR block for the public subnets"
  type        = list(string)
  default     = []
}

variable "create_nat_gateway" {
  description = "Create the NAT Gateway resouces"
  type        = bool
  default     = false
}
