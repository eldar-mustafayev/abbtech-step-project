resource "aws_security_group" "service" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    security_groups = [ var.alb_security_group ]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    creator = "Terraform"
  }
}

resource "aws_security_group" "ssh" {
  name = "developer-access"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [ "85.132.9.239/32", "185.161.226.58/32" ]
  }

  tags = {
    creator = "Terraform"
  }
}

module "astg" {
  source = "../../../modules/astg"

  port             = 80
  name             = "front-end"
  subnets          = var.subnets
  vpc_id           = var.vpc_id
  ami              = "ami-0eb7496c2e0403237"# Amazon Linux 2 #"ami-03f35ba71e8ead526" #nginx server
  instance_type    = "t2.micro"
  min_instances    = 1
  max_instances    = 3
  security_groups  = [
    aws_security_group.ssh.id,
    aws_security_group.service.id
  ]

  config = base64encode(
    templatefile(
      "${path.root}/user-data/front-end-config.sh",
      { BACKEND_HOST = var.backend_host }
    )
  )
}

resource "aws_lb_listener" "default" {
  load_balancer_arn  = var.alb_arn
  protocol           = "HTTP"
  port               = 80

  default_action {
    type = "forward"
    target_group_arn = module.astg.target_group_arn
  }
}