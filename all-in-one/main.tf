terraform {
  required_version = ">= 0.12, < 0.13"

  required_providers {
    aws = "~> 2.51"
  }
}

/* VPC & Subnets */

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "priv_subnets" {
  count = length(var.cidr_private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "pub_subnets" {
  count = length(var.cidr_public_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tf-example"
  }
}

/* Internet Gateway & Routing */

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "tf-example"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "tf-example"
  }
}

resource "aws_route_table_association" "rta_public" {
  count = length(aws_subnet.pub_subnets)
  subnet_id      = aws_subnet.pub_subnets[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

/* NAT Gateway & Routing  (Optional) */

resource "aws_eip" "eip" {
  count = var.create_nat_gateway ? length(aws_subnet.pub_subnets) : 0
  vpc      = true
}

resource "aws_nat_gateway" "nat_priv" {
  count = var.create_nat_gateway ? length(aws_subnet.pub_subnets) : 0
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.pub_subnets[count.index].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "tf-example"
  }
}

resource "aws_route_table" "rt_private" {
  count = var.create_nat_gateway ? length(aws_nat_gateway.nat_priv) : 0
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_priv[count.index].id
  }

  tags = {
    Name = "tf-example"
  }
}

resource "aws_route_table_association" "rta_private" {
count = var.create_nat_gateway ? length(aws_subnet.priv_subnets) : 0
  subnet_id = aws_subnet.priv_subnets[count.index].id
  route_table_id = aws_route_table.rt_private[count.index].id
}

/* EC2 Instance */

resource "aws_launch_configuration" "example" {
  image_id        = var.instance_ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.sg_instance.id]
  key_name = aws_key_pair.ec2key.key_name

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup python -m SimpleHTTPServer ${var.server_port} &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = aws_subnet.pub_subnets[*].id

  target_group_arns = [aws_lb_target_group.tg_asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "tf-terraform"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "sg_instance" {
  name = "tf-example-instance"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_key_pair" "ec2key" {
  key_name = "publicKey"
  public_key = file(var.public_key_path)
}

/* Application Load Balancer */

resource "aws_lb" "example" {
  name               = "tf-example-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.pub_subnets[*].id
  security_groups    = [aws_security_group.sg_alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "http_asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_asg.arn
  }
}

resource "aws_lb_target_group" "tg_asg" {
  name     = "tf-example-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "sg_alb" {
  name = "tf-example-alb"
  vpc_id = aws_vpc.vpc.id

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
