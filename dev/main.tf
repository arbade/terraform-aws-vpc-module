provider "aws" {
  max_retries = 1337
  region      = "eu-central-1"
  alias       = "test"
}

module "vpc" {
  source = "../"

  name = "VPC-arbade"
  env  = "dev"
  cidr = "10.201.0.0/16"
  azs = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]
  instance_tenancy = "default"

  enable_ipv6 = true
  enable_ddns = true

  enable_public_subnets   = true
  enable_private_subnets  = true
  enable_nat_gateway      = true

  providers = {
    aws.src = aws.test
  }
}
