module "network" {
  source = "../network"
}

data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_security_group" "backend" {
  name   = "back-end"
  vpc_id = module.network.vpc_id

  ingress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
    self        = true
  }
}

resource "aws_security_group" "database" {
  name   = "database"
  vpc_id = module.network.vpc_id

  ingress {
    to_port         = 3306
    from_port       = 3306
    protocol        = "tcp"
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

resource "aws_security_group" "alb" {
  name   = "alb-back-end"
  vpc_id = module.network.vpc_id

  ingress {
    to_port     = 0
    from_port   = 0
    protocol    = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_lb" "this" {
  name               = "back-end"
  subnets            = module.network.subnets
  load_balancer_type = "application"
  internal           = true
  security_groups    = [
    aws_security_group.backend.id,
    aws_security_group.alb.id
  ]
}

module "service1" {
  source = "./services/service1"

  alb_arn                = aws_lb.this.arn
  backend_security_group = aws_security_group.backend.id

  db_host     = aws_db_instance.main.address
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}
