# --------------------------------------------------------
# VPC
# --------------------------------------------------------
resource "aws_vpc" "myVpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myVpc"
  }
}

# --------------------------------------------------------
# Public Subnets
# --------------------------------------------------------
resource "aws_subnet" "publicSubnet1" {
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PUBLIC_SUBNET_1"
  }
}

resource "aws_subnet" "publicSubnet2" {
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PUBLIC_SUBNET_2"
  }
}

# --------------------------------------------------------
# Private Subnets
# --------------------------------------------------------
resource "aws_subnet" "privateSubnet1" {
  vpc_id            = aws_vpc.myVpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "PRIVATE_SUBNET_1"
  }
}

resource "aws_subnet" "privateSubnet2" {
  vpc_id            = aws_vpc.myVpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "PRIVATE_SUBNET_2"
  }
}

# --------------------------------------------------------
# Internet Gateway & Public Routing
# --------------------------------------------------------
resource "aws_internet_gateway" "myInternetGateway" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "myInternetGateway"
  }
}

resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.myVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myInternetGateway.id
  }

  tags = {
    Name = "publicRouteTable"
  }
}

resource "aws_route_table_association" "publicSubnet1Association" {
  subnet_id      = aws_subnet.publicSubnet1.id
  route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_route_table_association" "publicSubnet2Association" {
  subnet_id      = aws_subnet.publicSubnet2.id
  route_table_id = aws_route_table.publicRouteTable.id
}

# --------------------------------------------------------
# NAT Gateways & Elastic IPs
# --------------------------------------------------------
resource "aws_eip" "nat_eip1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.myInternetGateway]

  tags = {
    Name = "nat-gateway-eip1"
  }
}

resource "aws_eip" "nat_eip2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.myInternetGateway]

  tags = {
    Name = "nat-gateway-eip2"
  }
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.publicSubnet1.id

  tags = {
    Name = "main-nat-gateway1"
  }

  depends_on = [aws_internet_gateway.myInternetGateway]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.publicSubnet2.id

  tags = {
    Name = "main-nat-gateway2"
  }

  depends_on = [aws_internet_gateway.myInternetGateway]
}

# --------------------------------------------------------
# Private Routing
# --------------------------------------------------------
resource "aws_route_table" "privateRouteTable1" {
  vpc_id = aws_vpc.myVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "privateRouteTable1"
  }
}

resource "aws_route_table" "privateRouteTable2" {
  vpc_id = aws_vpc.myVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat2.id
  }

  tags = {
    Name = "privateRouteTable2"
  }
}

resource "aws_route_table_association" "privateSubnet1Association" {
  subnet_id      = aws_subnet.privateSubnet1.id
  route_table_id = aws_route_table.privateRouteTable1.id
}

resource "aws_route_table_association" "privateSubnet2Association" {
  subnet_id      = aws_subnet.privateSubnet2.id
  route_table_id = aws_route_table.privateRouteTable2.id
}