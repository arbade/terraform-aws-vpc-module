#------------------------------------------------------------------------------#
# VPC Attachment
#------------------------------------------------------------------------------#

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  subnet_ids = [
    for subnet in aws_subnet.private :
    subnet.id
  ]

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main.id

  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  dns_support  = "enable"
  ipv6_support = var.enable_ipv6 ? "enable" : "disable"

  tags = {
    Name      = local.name
  }

  lifecycle {
    ignore_changes = [
      ipv6_support,
    ]
  }
}

#------------------------------------------------------------------------------#
# Route Table
#------------------------------------------------------------------------------#

resource "aws_ec2_transit_gateway_route_table" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name      = local.name
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_attachment_id  = concat(aws_ec2_transit_gateway_vpc_attachment.main.*.id, [""])[0]
  transit_gateway_route_table_id = concat(aws_ec2_transit_gateway_route_table.main.*.id, [""])[0]
}

resource "aws_ec2_tag" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  resource_id = concat(aws_ec2_transit_gateway_vpc_attachment.main.*.id, [""])[0]
  key         = "Name"
  value       = local.name
}

#------------------------------------------------------------------------------#
# Propagations
#------------------------------------------------------------------------------#

resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  for_each = var.enable_transit_gateway ? toset(var.transit_gateway_propagations[*].attachment_id) : []

  transit_gateway_route_table_id = concat(aws_ec2_transit_gateway_route_table.main.*.id, [""])[0]
  transit_gateway_attachment_id  = each.value
}

#------------------------------------------------------------------------------#
# Static Routes
#------------------------------------------------------------------------------#

resource "aws_ec2_transit_gateway_route" "main" {
  for_each = var.enable_transit_gateway ? toset(var.transit_gateway_static_routes[*].attachment_id) : []

  transit_gateway_route_table_id = concat(aws_ec2_transit_gateway_route_table.main.*.id, [""])[0]
  transit_gateway_attachment_id  = each.value

  destination_cidr_block = element([
    for transit_gateway_static_route in var.transit_gateway_static_routes :
    transit_gateway_static_route.cidr_block
    if transit_gateway_static_route.attachment_id == each.value
  ], 0)
}
