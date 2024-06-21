resource "aws_vpc" "test-vpc" {
  cidr_block           = "10.0.0.0/27"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "test_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = "10.0.0.0/28" #cidrsubnet(aws_vpc.test-vpc.cidr_block, 4, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zones
  tags = {
    Name = "cs6-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = "10.0.0.16/28" #cidrsubnet(aws_vpc.test-vpc.cidr_block, 4, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zones
  tags = {
    Name = "cs6-private-subnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "cs_internet_gateway"
  }
}

resource "aws_route_table" "cs6-public-route" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "cs_public_route_table"
  }
}

resource "aws_route_table" "cs6-private-route" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "cs_private_route_table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  #count          = length(var.availability_zones)
  route_table_id = aws_route_table.cs6-public-route.id
  subnet_id      = aws_subnet.public_subnet.id

}


resource "aws_route_table_association" "private_subnet_assoc" {
  #count          = length(var.availability_zones)
  route_table_id = aws_route_table.cs6-private-route.id
  subnet_id      = aws_subnet.private_subnet.id
}

# resource "aws_route" "private_route" {
#   route_table_id         = aws_route_table.cs6-private-route.id
#   vpc_endpoint_id        = aws_vpc_endpoint_route_table_association.vpc_s3_access_endpoint.id
#   destination_cidr_block = "10.0.0.16/28"
# }

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.test-vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "My_security_group"
  }
}
