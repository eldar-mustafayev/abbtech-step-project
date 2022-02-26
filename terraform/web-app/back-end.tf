resource "aws_security_group" "backend" {
  name   = "back-end"
  vpc_id = data.aws_vpc.default.id

  ingress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
    self        = true
  }
}

resource "aws_security_group" "database" {
  name   = "database"
  vpc_id = data.aws_vpc.default.id

  ingress {
    to_port         = 3306
    from_port       = 3306
    protocol        = "TCP"
    security_groups = [ aws_security_group.backend.id ]
  }
}

resource "aws_db_instance" "main" {
  engine                 = "mysql"
  engine_version         = "8.0"
  allocated_storage      = 10
  max_allocated_storage  = 20
  instance_class         = "db.t2.micro"
  availability_zone      = data.aws_availability_zones.available.names[0]
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [ aws_security_group.database.id ]
}

resource "aws_security_group" "backend_alb" {
  name   = "alb-backend"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = [ data.aws_vpc.default.cidr_block ]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_lb" "backend" {
  name               = "back-end"
  subnets            = data.aws_subnets.default.ids
  load_balancer_type = "application"
  internal           = true
  security_groups    = [
    aws_security_group.backend.id,
    aws_security_group.backend_alb.id
  ]
}

module "backend_service1" {
  source = "./backend-services/service1"

  alb_arn                = aws_lb.backend.arn
  alb_arn_suffix         = aws_lb.backend.arn_suffix
  vpc_id                 = data.aws_vpc.default.id
  subnets                = data.aws_subnets.default.ids
  backend_security_group = aws_security_group.backend.id

  db_host     = aws_db_instance.main.address
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

