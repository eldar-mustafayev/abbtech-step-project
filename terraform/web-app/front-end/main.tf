module "network" {
  source = "../network"
}

resource "aws_security_group" "alb" {
  name = "alb-front-end"
  vpc_id = module.network.vpc_id

  ingress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
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
  name               = "front-end"
  security_groups    = [ aws_security_group.alb.id ]
  subnets            = module.network.subnets
  load_balancer_type = "application"
}

module "service1" {
  source = "./services/service1"
  alb_arn = aws_lb.this.arn
  alb_security_group = aws_security_group.alb.id

  backend_host = var.backend_dns
}