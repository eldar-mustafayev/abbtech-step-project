output "target_group_arn" {
    value = aws_lb_target_group.this.arn
}

output "name" {
  value = aws_autoscaling_group.this.name
}

output "tg_arn_suffix" {
  value = aws_lb_target_group.this.arn_suffix
}