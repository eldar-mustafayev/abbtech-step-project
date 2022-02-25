module "network" {
  source = "../../../network"
}

resource "aws_security_group" "service" {
  vpc_id = module.network.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
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
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "85.132.9.239/32", "185.161.226.58/32" ]
  }

  tags = {
    creator = "Terraform"
  }
}


# module "template_files" {
#   source = "hashicorp/dir/template"

#   base_dir = "../../../user-data"
#   template_file_suffix = ".sh"
#   template_vars = {
#     DB_NAME = var.db_name,
#     DB_USER = var.db_username,
#     DB_PASSWORD = var.db_password,
#     DB_HOST = var.db_host,
#   }
# }

# data "local_file" "config" {
#   filename = "${path.root}user-data/back-end-config.sh"
# }


module "astg" {
  source = "../../../../modules/astg"

  port             = 8080
  name             = "back-end"
  subnets          = module.network.subnets
  vpc_id           = module.network.vpc_id
  ami              = "ami-0eb7496c2e0403237"# Amazon Linux 2    #"ami-03f35ba71e8ead526" #nginx server
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