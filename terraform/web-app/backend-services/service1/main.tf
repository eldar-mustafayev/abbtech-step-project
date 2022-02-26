resource "aws_security_group" "service" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = [ var.backend_security_group ]
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
  name = "developer-access-back-end-1"
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

  port             = 8080
  name             = "back-end"
  subnets          = var.subnets
  vpc_id           = var.vpc_id
  ami              = "ami-0eb7496c2e0403237"# Amazon Linux 2
  instance_type    = "t2.micro"
  min_instances    = 1
  max_instances    = 3
  security_groups  = [
    aws_security_group.ssh.id,
    aws_security_group.service.id,
    var.backend_security_group
  ]

  config = base64encode(
    templatefile(
      "${path.root}/user-data/back-end-config.sh",
      {
        DB_NAME = var.db_name,
        DB_USER = var.db_username,
        DB_PASSWORD = var.db_password,
        DB_HOST = var.db_host,
      }
    )
  ) 
}

resource "aws_lb_listener" "default" {
  load_balancer_arn  = var.alb_arn
  protocol           = "HTTP"
  port               = 8080

  default_action {
    type = "forward"
    target_group_arn = module.astg.target_group_arn
  }
}

resource "aws_autoscaling_policy" "this" {
  depends_on  = [ module.astg ]
  name        = "requests_count_scaling_policy"
  policy_type = "TargetTrackingScaling"

  autoscaling_group_name = module.astg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = format("%s/%s", var.alb_arn_suffix, module.astg.tg_arn_suffix)
    }

    target_value = 30
  }
}