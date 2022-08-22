#------------------------------------------------------------------------------#
# Terraform version constraints
#------------------------------------------------------------------------------#

terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      version               = ">= 3.49.0"
      configuration_aliases = [aws.src]
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}
