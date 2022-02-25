resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "eu-central-1a"
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "eu-central-1b"
}

resource "aws_default_subnet" "default_az3" {
  availability_zone = "eu-central-1c"
}

# resource "aws_security_group" "web" {
#   name = "front-end"
#   vpc_id = aws_default_vpc.default.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = [ "0.0.0.0/0" ]
#   }
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [ "0.0.0.0/0" ]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = [ "0.0.0.0/0" ]
#   }

#   tags = {
#     creator = "Terraform"
#   }
# }

# resource "aws_security_group" "ssh" {
#   name = "developer-access"
#   vpc_id = aws_default_vpc.default.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [ "85.132.9.239/32" ]
#   }

#   tags = {
#     creator = "Terraform"
#   }
# }

# resource "aws_security_group" "service" {
#   name = "back-end"
#   vpc_id = aws_default_vpc.default.id

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     security_groups = [ aws_security_group.web.id ]
#   }

#   tags = {
#     creator = "Terraform"
#   }
# }