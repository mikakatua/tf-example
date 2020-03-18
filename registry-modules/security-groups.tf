module "instance-sg" {
  source = "terraform-aws-modules/security-group/aws"
  name = local.identifier
  tags = local.common_tags
  description = "Security group for ASG"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.server_port
      to_port     = var.server_port
      protocol    = "tcp"
      description = "Service traffic"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "alb-sg" {
  source = "terraform-aws-modules/security-group/aws"
  name = local.identifier
  tags = local.common_tags
  description = "Security group for ALB"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = local.http_port
      to_port     = local.http_port
      protocol    = "tcp"
      description = "HTTP traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "db-sg" {
  source = "terraform-aws-modules/security-group/aws"
  name = local.identifier
  tags = local.common_tags
  description = "Security group for RDS"
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = module.rds.this_db_instance_port
      to_port                  = module.rds.this_db_instance_port
      protocol                 = "tcp"
      source_security_group_id = module.instance-sg.this_security_group_id
    },
  ]
}
