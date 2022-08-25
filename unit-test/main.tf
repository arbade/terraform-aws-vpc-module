provider "aws" {
  max_retries = 1337
  region      = "eu-central-1"
  alias       = "test"
}

resource "random_pet" "this" {
  length = 1
}

module "vpc_test" {
  source = "../"

  name = "VPC"
  #name = "terratest-arbade-vpc-${random_pet.this.id}"
  env  = "test"
  cidr = "10.100.0.0/24"
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
