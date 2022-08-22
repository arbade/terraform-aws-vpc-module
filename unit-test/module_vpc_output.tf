output "vpc_id" {
    description = "The ID of the VPC"
    value = module.vpc_test.id
}

output "cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc_test.cidr_block
}

output "public_subnet_cidr_blocks_one"{
    value = module.vpc_test.nat_gateway_public_ips[0].tags
    
}

output "public_subnet_cidr_blocks_two"{
    value = module.vpc_test.nat_gateway_public_ips[1].tags
    
}

output "public_subnet_cidr_blocks_three"{
    value = module.vpc_test.nat_gateway_public_ips[2].tags
    
}

output "private_subnet_cidr_block"{
    value = module.vpc_test.private_subnet_cidr_blocks
    
}

#output "database_subnet_cidr_blocks"{
#  value = module.vpc_test.database_subnet_cidr_blocks
#}

output "public_subnets"{
  value = module.vpc_test.public_subnets
}

output "private_subnets"{
  value = module.vpc_test.private_subnets
}

#output "parent_zone_id"{
#  description = "Public DNS zone where VPC resources are registered"
#  value = module.vpc_test.zone_id
#}

#output "vgw_id"{
#  description = "The ID of the VPN Gateway"
#  value = module.vpc_test.vgw_id
#}

output "transit_gateway_route_table_id"{
  value = module.vpc_test.transit_gateway_route_table_id
}

output "transit_gateway_vpc_attachment_id"{
  value = module.vpc_test.transit_gateway_vpc_attachment_id
}

#output "main" {
#    value = module.vpc_test
#}