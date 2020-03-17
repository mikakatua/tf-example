/* VPC & Subnets */

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_subnet" "priv_subnets" {
  count = length(var.cidr_private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_subnet" "pub_subnets" {
  count = length(var.cidr_public_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = "true"

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

/* Internet Gateway & Routing */

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
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

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat_priv" {
  count = var.create_nat_gateway ? length(aws_subnet.pub_subnets) : 0
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.pub_subnets[count.index].id

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_route_table" "rt_private" {
  count = var.create_nat_gateway ? length(aws_nat_gateway.nat_priv) : 0
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_priv[count.index].id
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_route_table_association" "rta_private" {
count = var.create_nat_gateway ? length(aws_subnet.priv_subnets) : 0
  subnet_id = aws_subnet.priv_subnets[count.index].id
  route_table_id = aws_route_table.rt_private[count.index].id
}
