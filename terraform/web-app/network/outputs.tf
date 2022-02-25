output "vpc_id" {
  value = aws_default_vpc.default.id
}

output "subnets" {
  value = [
    aws_default_subnet.default_az1.id,
    aws_default_subnet.default_az2.id,
    aws_default_subnet.default_az3.id,
  ]
}

# output "security_groups" {
#   value = {
#     ssh = aws_security_group.ssh.id,
#     web = aws_security_group.web.id,
#     service = aws_security_group.service.id
#   }
# }