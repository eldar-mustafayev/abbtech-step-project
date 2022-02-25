resource "aws_launch_template" "this" {
  name                   = var.name
  image_id               = var.ami #nginx server
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_groups
  user_data              = var.config
  key_name               = "main"
  tags = {
    creator = "Terraform"
  }
}

resource "aws_autoscaling_group" "this" {
  name     = var.name
  max_size = var.max_instances
  min_size = var.min_instances
  vpc_zone_identifier = var.subnets

  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "this" {
  name     = var.name
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    matcher = "200-299"
    path = "/status"
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn = aws_lb_target_group.this.arn
}