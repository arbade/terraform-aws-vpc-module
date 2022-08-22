terraform {
  backend "s3" {
    
    bucket         = "arbade-modules"
    key            = "arbade/dev/arbade-aws-module-vpc/arbade-vpc-dev"
    region         = "eu-central-1"
    dynamodb_table = "arbade-dev-locktable"
  }
}