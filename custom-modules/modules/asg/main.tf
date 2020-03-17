locals {
  instance_ami = "ami-0e38b48473ea57778" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  min_instances = 2
  max_instances = 10
}

/* EC2 Instance */

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    dbhost = var.database_host
    dbport = var.database_port
    dbuser = var.database_user
    dbpass = var.database_pass
    dbname = var.database_name
  }
}

resource "aws_launch_configuration" "example" {
  image_id        = local.instance_ami
  instance_type   = local.instance_type
  security_groups = [aws_security_group.sg_instance.id]
  key_name = aws_key_pair.ec2key.key_name

  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = var.subnet_ids

  target_group_arns = var.alb_tg_arns
  health_check_type = "ELB"

  min_size = local.min_instances
  max_size = local.max_instances

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_security_group" "sg_instance" {
  name = "${var.name}-instance"
  vpc_id = var.vpc_id

   tags = merge(
     {
       "Name" = var.name
     },
     var.tags
   )
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.sg_instance.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.sg_instance.id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.sg_instance.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_key_pair" "ec2key" {
  key_name = "publicKey"
  public_key = file(var.public_key_path)
}
