locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

# Subredes públicas
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-public-${replace(each.value, "/", "-")}"
    Tier = "public"
  })
}

# Subredes privadas
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)

  vpc_id     = aws_vpc.this.id
  cidr_block = each.value

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-private-${replace(each.value, "/", "-")}"
    Tier = "private"
  })
}

# Tabla de rutas pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-rt-public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway (simplificado, un solo NAT opcional)
resource "aws_eip" "nat" {
  count      = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0
  vpc        = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = element(values(aws_subnet.public)[*].id, 0)

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-nat"
  })
}

# Tabla de rutas privada (usando NAT)
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-rt-private"
  })
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id = each.value.id
  route_table_id = var.enable_nat_gateway ?
    aws_route_table.private[0].id :
    aws_route_table.public.id
}
