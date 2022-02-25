variable "instance_type" {
  type = string
}

variable "ami" {
  type = string
}

variable "config" {
  type = any
}

variable "name" {
  type = string
}

variable "port" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "max_instances" {
  type = number
}

variable "min_instances" {
  type = number
}