terraform {
  required_version = ">= 0.12, < 0.13"

  required_providers {
    aws = "~> 2.51"
    template = "~> 2.1"
    random = "~> 2.2"
    null = "~> 2.1"
  }
}

locals {
  identifier = "tf-example"
  common_tags = {
    Project = "web-cluster"
    Environment = "test"
  }
}

/* VPC resources */

data "aws_region" "current" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"
  name = local.identifier
  tags = local.common_tags
  cidr = "10.0.0.0/16"
  azs = [ "${data.aws_region.current.name}a", "${data.aws_region.current.name}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
}

/* Auto Scaling Group */

locals {
  instance_ami = "ami-0e38b48473ea57778" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  min_instances = 2
  max_instances = 10
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    dbhost = module.rds.this_db_instance_address
    dbport = module.rds.this_db_instance_port
    dbuser = module.rds.this_db_instance_username
    dbpass = module.rds.this_db_instance_password
    dbname = module.rds.this_db_instance_name
  }
}

resource "aws_key_pair" "ec2key" {
  key_name = "publicKey"
  public_key = file(var.public_key_path)
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  name = local.identifier

  tags = concat([
    {
      key                 = "Name"
      value               = local.identifier
      propagate_at_launch = true
    },
  ],
  [
    for key,val in local.common_tags: {
      key                 = key
      value               = val
      propagate_at_launch = true
    }
  ])

  # Launch configuration
  lc_name = "${local.identifier}-lc"
  image_id        = local.instance_ami
  instance_type   = local.instance_type
  security_groups = [module.instance-sg.this_security_group_id]
  key_name = aws_key_pair.ec2key.key_name

  user_data = data.template_file.user_data.rendered

  # Auto scaling group
  asg_name                  = "${local.identifier}-asg"
  vpc_zone_identifier       = module.vpc.public_subnets
  target_group_arns         = module.alb.target_group_arns
  health_check_type         = "ELB"
  min_size                  = local.min_instances
  max_size                  = local.max_instances
  desired_capacity          = local.min_instances
  wait_for_elb_capacity     = 0
}

/* Application Load Balancer (ALB) */

locals {
  http_port = 80
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  name = "${local.identifier}-alb"
  tags = local.common_tags
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.alb-sg.this_security_group_id]
  load_balancer_type = "application"

  target_groups = [
    {
      name             = "${local.identifier}-tg"
      backend_protocol = "HTTP"
      backend_port     = var.server_port
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = local.http_port
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

/* RDS resources */

locals {
  db_storage = 10 # GB
  db_engine = "mariadb"
  db_engine_ver = "10.3"
  db_instance = "db.t2.micro"
  db_port = 3306
  db_name = "example"
  db_user = "admin"
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"
  identifier = "${local.identifier}-db"
  tags = local.common_tags
  vpc_security_group_ids = [module.db-sg.this_security_group_id]
  subnet_ids = module.vpc.private_subnets
  name     = local.db_name
  username = local.db_user
  password = random_password.db_pass.result
  port     = local.db_port
  engine            = local.db_engine
  engine_version    = local.db_engine_ver
  instance_class    = local.db_instance
  allocated_storage = local.db_storage
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  # disable backups to create DB faster
  backup_retention_period = 0
  # DB parameter group
  family = "${local.db_engine}${local.db_engine_ver}"
  # DB option group
  major_engine_version = local.db_engine_ver
}

resource "random_password" "db_pass" {
  length = 16
  special = false
}
