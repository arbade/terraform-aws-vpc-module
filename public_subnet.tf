#------------------------------------------------------------------------------#
# Public subnet
#------------------------------------------------------------------------------#

resource "aws_subnet" "public" {
  count = var.enable_public_subnets ? length(var.azs) : 0

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = cidrsubnet(aws_vpc.main.cidr_block, 4, 1 + count.index)
  ipv6_cidr_block                 = var.enable_ipv6 ? cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1 + count.index) : null
  availability_zone               = var.azs[count.index]
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = var.enable_ipv6

  tags = {
    #Name      = format("Public-${var.env}-%s", var.azs[count.index])
    Name      = format("Public-%s", var.azs[count.index])
    Project   = local.name
    Tier      = "Public"
    Terraform = true
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

#------------------------------------------------------------------------------#
# Gateways
#------------------------------------------------------------------------------#

resource "aws_internet_gateway" "public" {
  count = var.enable_public_subnets ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = {
    Name      = local.name
    Terraform = true
  }
}

resource "aws_egress_only_internet_gateway" "public" {
  count = var.enable_ipv6 ? 1 : 0

  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "public" {
  count = var.enable_public_subnets && var.enable_nat_gateway ? length(var.azs) : 0

  vpc = true

   tags = {
    #Name      = format("NGW-${var.env}%s", var.azs[count.index])
    Name      = format("NGW-%s", var.azs[count.index])
    Project   = local.name
    Terraform = true
  }
}


resource "aws_nat_gateway" "public" {
  count = var.enable_public_subnets && var.enable_nat_gateway ? length(var.azs) : 0

  allocation_id = aws_eip.public[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name      = var.azs[count.index]
    Project   = local.name
    Terraform = true
  }
}

#------------------------------------------------------------------------------#
# Routes
#------------------------------------------------------------------------------#

resource "aws_route_table" "public" {
  count = var.enable_public_subnets ? 1 : 0

  vpc_id = aws_vpc.main.id

  # NAT Gateway
  dynamic "route" {
    for_each = [for ipv4_default_route in ["0.0.0.0/0"] : {
      cidr = ipv4_default_route
    } if var.enable_public_subnets && var.enable_nat_gateway]

    content {
      cidr_block = route.value.cidr
      gateway_id = aws_internet_gateway.public[0].id
    }
  }

  # IPv6 Gateway
  dynamic "route" {
    for_each = [for ipv6_default_route in ["::/0"] : {
      cidr = ipv6_default_route
    } if var.enable_public_subnets && var.enable_ipv6]

    content {
      ipv6_cidr_block = route.value.cidr
      gateway_id      = aws_internet_gateway.public[0].id
    }
  }

   tags = {
    Name      = "Public-${var.env}"
    Project   = local.name
    Tier      = "Public"
    Terraform = true
    
  }
}

resource "aws_route_table_association" "public" {
  count = var.enable_public_subnets ? length(var.azs) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

