terraform {
  required_version = ">= 0.12, < 0.13"

  required_providers {
    aws = "~> 2.51"
    template = "~> 2.1"
  }
}

locals {
  common_tags = {
    Project = "web-cluster"
    Environment = "test"
  }
}

module "vpc" {
  source = "./modules/vpc"
  name = "tf-example"
  tags = local.common_tags
  cidr_vpc = "10.0.0.0/16"
  cidr_private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  cidr_public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  create_nat_gateway = true
}

module "asg" {
  source = "./modules/asg"
  name = "tf-example"
  tags = local.common_tags
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  alb_tg_arns = [module.alb.target_group]
  server_port = var.port
}

module "alb" {
  source = "./modules/alb"
  name = "tf-example"
  tags = local.common_tags
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  target_port = var.port
}
