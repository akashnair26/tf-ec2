resource "aws_vpc" "vpc_dev" {
    cidr_block = var.vpcCidr
    instance_tenancy = "default"
    tags = {
        Name = "vpc_dev"
    }
}

resource "aws_subnet" "publicSubnet1" {
    vpc_id = aws_vpc.vpc_dev.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "publicSubnet1"
    }
}

resource "aws_subnet" "publicSubnet2" {
    vpc_id = aws_vpc.vpc_dev.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "publicSubnet2"
    }
}

resource "aws_subnet" "privateSubnet1" {
    vpc_id = aws_vpc.vpc_dev.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "us-east-2a"
    tags = {
        Name = "privateSubnet1"
    }
}

resource "aws_subnet" "privateSubnet2" {
    vpc_id = aws_vpc.vpc_dev.id
    cidr_block = "10.0.20.0/24"
    availability_zone = "us-east-2b"
    tags = {
        Name = "privateSubnet2"
    }
}

# internet Gateway

resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc_dev.id
}

resource "aws_eip" "natEIP" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat1" {
  subnet_id = aws_subnet.publicSubnet1.id
  allocation_id = aws_eip.natEIP.id
}

resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.vpc_dev.id
}

resource "aws_route_table" "privateRouteTable" {
  vpc_id = aws_vpc.vpc_dev.id
}

resource "aws_route" "publicRoute" {
  route_table_id = aws_route_table.publicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw1.id
}

resource "aws_route" "privateRoute" {
  route_table_id = aws_route_table.privateRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat1.id
}

resource "aws_route_table_association" "public1" {
  subnet_id = aws_subnet.publicSubnet1.id
  route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_route_table_association" "public2" {
  subnet_id = aws_subnet.publicSubnet2.id
  route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_route_table_association" "private1" {
  subnet_id = aws_subnet.privateSubnet1.id
  route_table_id = aws_route_table.privateRouteTable.id
}

resource "aws_route_table_association" "private2" {
  subnet_id = aws_subnet.privateSubnet2.id
  route_table_id = aws_route_table.privateRouteTable.id
}