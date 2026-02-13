# Use standard Terraform AWS modules where possible.
# See https://registry.terraform.io/browse/modules?provider=aws

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.89.0"
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  name        = var.project_name
  description = var.project_description
  region      = var.aws_region

  # Base for network addresses
  vpc_cidr = "10.0.0.0/16"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "${local.name}-container"
  container_port = var.app_port

  tags = {
    Name       = local.name
    Repository = "https://github.com/Talent-Catalog/tc-api"
  }
}
