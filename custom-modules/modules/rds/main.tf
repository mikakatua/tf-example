locals {
  db_storage = 10 # GB
  db_engine = "mariadb"
  db_instance = "db.t2.micro"
  db_port = 3306
}

resource "aws_db_instance" "example" {
  identifier          = var.name
  engine              = local.db_engine
  allocated_storage   = local.db_storage
  instance_class      = local.db_instance
  name                = var.database_name
  username            = var.database_user
  password            = var.database_pass
  db_subnet_group_name   = aws_db_subnet_group.example.name
  vpc_security_group_ids = [aws_security_group.sg_database.id]
  skip_final_snapshot = true  # <-- Allows 'terraform destroy' without final snapshot

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_db_subnet_group" "example" {
  name       = "${var.name}-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_security_group" "sg_database" {
  name = "${var.name}-database"
  vpc_id = var.vpc_id

   tags = merge(
     {
       "Name" = var.name
     },
     var.tags
   )
}

resource "aws_security_group_rule" "allow_mysql_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.sg_database.id

  from_port   = local.db_port
  to_port     = local.db_port
  protocol    = "tcp"
  source_security_group_id = var.client_sg_id
}
