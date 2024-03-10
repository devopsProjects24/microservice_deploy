# vpc for cluster

resource "aws_vpc" "cloudinfra_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloudinfra_vpc"
  }
}

# public subnets
resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.cloudinfra_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# private subnets
resource "aws_subnet" "private_subnets" {
  count      = 2
  vpc_id     = aws_vpc.cloudinfra_vpc.id
  cidr_block = "10.0.${count.index + 10}.0/24"

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

# internet gateway
resource "aws_internet_gateway" "cloudinfra_igw" {
  vpc_id = aws_vpc.cloudinfra_vpc.id

  tags = {
    Name = "cloudinfra-igw"
  }
}

# route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.cloudinfra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudinfra_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_associations" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# route table for private subnet
resource "aws_route_table" "private_route_tables" {
  vpc_id = aws_vpc.cloudinfra_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# Associate private subnets with their respective route tables
resource "aws_route_table_association" "private_subnet_associations" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables.id
}

