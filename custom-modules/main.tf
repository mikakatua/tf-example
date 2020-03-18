terraform {
  required_version = ">= 0.12, < 0.13"

  required_providers {
    aws = "~> 2.51"
    template = "~> 2.1"
    random = "~> 2.2"
  }
}

locals {
  identifier = "tf-example"
  common_tags = {
    Project = "web-cluster"
    Environment = "test"
  }
  dbname = "example"
  dbuser = "admin"
}

module "vpc" {
  source = "./modules/vpc"
  name = local.identifier
  tags = local.common_tags
  cidr_vpc = "10.0.0.0/16"
  cidr_private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  cidr_public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  create_nat_gateway = true
}

module "asg" {
  source = "./modules/asg"
  name = local.identifier
  tags = local.common_tags
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  alb_tg_arns = [module.alb.target_group]
  server_port = var.port
  database_host = module.rds.database_host
  database_port = module.rds.database_port
  database_name = module.rds.database_name
  database_user = module.rds.database_user
  database_pass = module.rds.database_pass
}

module "alb" {
  source = "./modules/alb"
  name = local.identifier
  tags = local.common_tags
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  target_port = var.port
}

module "rds" {
  source = "./modules/rds"
  name = local.identifier
  tags = local.common_tags
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  client_sg_id = module.asg.security_group
  database_name = local.dbname
  database_user = local.dbuser
  database_pass = random_password.dbpass.result
}

resource "random_password" "dbpass" {
  length = 16
  special = false
}
