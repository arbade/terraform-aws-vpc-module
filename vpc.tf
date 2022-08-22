#------------------------------------------------------------------------------#
# VPC
#------------------------------------------------------------------------------#

resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  instance_tenancy = var.instance_tenancy

  enable_dns_hostnames = var.enable_ddns
  enable_dns_support   = var.enable_ddns

  assign_generated_ipv6_cidr_block = var.enable_ipv6

   tags = {
    Name      = local.name
  }
}


