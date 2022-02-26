variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "alb_security_group" {
    type = string
}

variable "alb_arn" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "backend_host" {
  type = string
}

