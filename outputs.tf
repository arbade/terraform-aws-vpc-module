
#--
#output "database_subnets" {
#  description = "List of IDs of database subnets"
#
#  value = [
#    for subnet in aws_subnet.database :
#    subnet.id
#  ]
#}

#output "database_subnet_cidr_blocks" {
#  description = "List of CIDR blocks of database subnets"
#
#  value = [
#    for subnet in aws_subnet.database :
#    subnet.cidr_block
#  ]
#}
##--
output "private_subnets" {
  description = "List of IDs of private subnets"

  value = [
    for subnet in aws_subnet.private :
    subnet.id
  ]
}

output "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks of private subnets"

  value = [
    for subnet in aws_subnet.private :
    subnet.cidr_block
  ]
}
#--

output "private_route_tables" {
  value = [
    for route in aws_route_table.private :
    route.id
  ]
}
#--

output "public_subnets" {
  description = "List of IDs of public subnets"
  value = [
    for subnet in aws_subnet.public :
    subnet.id
  ]
}
#--

#output "private_reverse_zones" {
#  value = [
#    for reverse_zone in aws_route53_zone.private :
#    reverse_zone.id
#  ]
#}
#--

output "nat_gateway_public_ips" {
  value = aws_nat_gateway.public
}
#--

output "public_route_tables" {
  value = aws_route_table.public
}
#--

output "transit_gateway_vpc_attachment_id" {
  value = concat(aws_ec2_transit_gateway_vpc_attachment.main.*.id, [""])[0]
}
#--

output "transit_gateway_route_table_id" {
  value = concat(aws_ec2_transit_gateway_route_table.main.*.id, [""])[0]
}
#--

output "id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_id" {
  description = "DEPRECATED output for the ID of the VPC, use id ouput"
  value       = aws_vpc.main.id
}

output "cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "ipv6_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.ipv6_cidr_block
}
#--