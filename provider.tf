provider "aws" {
  max_retries = 1337
  region      = "eu-central-1"
}

provider "aws" {
  max_retries = 1337
  region      = "eu-west-2"
  alias       = "test"
}