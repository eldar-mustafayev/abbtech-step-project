provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "back_end" {
  source = "./back-end"

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

module "front_end" {
  source = "./front-end"

  backend_dns = module.back_end.dns_name
}
