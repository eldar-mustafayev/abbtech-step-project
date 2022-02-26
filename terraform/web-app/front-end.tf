resource "aws_security_group" "frontend_alb" {
  name = "alb-front-end"
  vpc_id = data.aws_vpc.default.id

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

resource "aws_lb" "frontend" {
  name               = "front-end"
  security_groups    = [ aws_security_group.frontend_alb.id ]
  subnets            = data.aws_subnets.default.ids
  load_balancer_type = "application"
}

module "frontend_service1" {
  source = "./frontend-services/service1"

  vpc_id             = data.aws_vpc.default.id
  subnets            = data.aws_subnets.default.ids
  alb_security_group = aws_security_group.frontend_alb.id
  alb_arn            = aws_lb.frontend.arn
  alb_arn_suffix     = aws_lb.frontend.arn_suffix
  backend_host       = aws_lb.backend.dns_name
}