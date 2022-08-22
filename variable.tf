#------------------------------------------------------------------------------#
# Global
#------------------------------------------------------------------------------#

variable "name" {
  description = "Name to be used on resources as identifier"
  type        = string
}

variable "env" {
  description = "Environment to be used on resources as identifier"
  type        = string
  default     = null
}

#variable "account_id_dns" {
#  description = "Account ID of AWS Account, where Route53 DNS is stored"
#  type        = string
#  default     = null
#}

#variable "account_role_dns" {
#  description = "Role Name to assume in account_id_dns"
#  type        = string
#  default     = null
#}

#------------------------------------------------------------------------------#
# VPC
#------------------------------------------------------------------------------#
#

variable "cidr" {
  description = "A CIDR Block notation of the whole VPC"
  type        = string
}

variable "azs" {
  description = "List of AZs the VPC should be built in"
  default = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]
}

variable "instance_tenancy" {
  description = "Tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "enable_ipv6" {
  description = "Set to true if you want to enable IPv6 within the VPC"
  default     = false
}

variable "enable_ddns" {
  description = "Set to enable DDNS in forward and reverse dns zone"
  default     = false
}

variable "parent_zone" {
  description = "DNS Parent Zone "
  type        = string
  default     = "alice-poc.com"
}

#------------------------------------------------------------------------------#
# Subnets
#------------------------------------------------------------------------------#

variable "enable_public_subnets" {
  description = "Set to false to disable creating the public subnets"
  default     = false
}

variable "enable_private_subnets" {
  description = "Set to false to disable creating the private subnets"
  default     = false
}

#------------------------------------------------------------------------------#
# Gateway
#------------------------------------------------------------------------------#

variable "enable_nat_gateway" {
  description = "Set to false to disable creating the NAT gateways"
  default     = false
}

variable "enable_transit_gateway" {
  description = "Should transit gateway be enabled?"
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = "ID of Transit Gateway"
  type        = string
  default     = null
}

variable "transit_gateway_propagations" {
  description = "List of maps of Transit Gateway Attachment IDs to propagate into Transit Gateway Route Table"
  default     = []
  type = list(object({
    attachment_id   = string
    cidr_block      = string
    ipv6_cidr_block = string
  }))
}

variable "transit_gateway_static_routes" {
  description = "List of maps of Transit Gateway Attachment IDs to propagate into Transit Gateway Route Table"
  default     = []
  type = list(object({
    attachment_id = string
    cidr_block    = string
  }))
}

variable "transit_gateway_default_route_table_association" {
  description = "Whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table"
  default     = true
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Whether the VPC Attachment should propagate routes with the EC2 Transit Gateway propagation default route table"
  default     = true
}


#variable "default_tags" {
#    type = map(string)
#    default = {}
#}
#
