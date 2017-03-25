# VPC
resource "aws_vpc" "ecs-cluster" {
  cidr_block           = "10.240.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags {
    Name = "ecs-cluster"
  }
}

# Subnets
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = "${aws_vpc.ecs-cluster.id}"
  cidr_block              = "10.240.10.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}a"

  tags {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = "${aws_vpc.ecs-cluster.id}"
  cidr_block              = "10.240.11.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}b"

  tags {
    Name = "public-subnet-2"
  }
}

# Subnets
resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = "${aws_vpc.ecs-cluster.id}"
  cidr_block              = "10.240.20.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}a"

  tags {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = "${aws_vpc.ecs-cluster.id}"
  cidr_block              = "10.240.21.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}b"

  tags {
    Name = "private-subnet-2"
  }
}

# Internet GW
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.ecs-cluster.id}"

  tags {
    Name = "ecs-cluster-internet-gateway"
  }
}

# NAT GW
resource "aws_eip" "nat-1-eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway-1" {
  allocation_id = "${aws_eip.nat-1-eip.id}"
  subnet_id     = "${aws_subnet.public-subnet-1.id}"
  depends_on    = ["aws_internet_gateway.internet-gateway"]
}

resource "aws_eip" "nat-2-eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway-2" {
  allocation_id = "${aws_eip.nat-2-eip.id}"
  subnet_id     = "${aws_subnet.public-subnet-2.id}"
  depends_on    = ["aws_internet_gateway.internet-gateway"]
}

#Route table
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.ecs-cluster.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet-gateway.id}"
  }

  tags {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public-subnet-1" {
  subnet_id      = "${aws_subnet.public-subnet-1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-subnet-2" {
  subnet_id      = "${aws_subnet.public-subnet-2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

#Route table
resource "aws_route_table" "private-1" {
  vpc_id = "${aws_vpc.ecs-cluster.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gateway-1.id}"
  }

  tags {
    Name = "private-route-table-1"
  }
}

resource "aws_route_table_association" "private-subnet-1" {
  subnet_id      = "${aws_subnet.private-subnet-1.id}"
  route_table_id = "${aws_route_table.private-1.id}"
}

resource "aws_route_table" "private-2" {
  vpc_id = "${aws_vpc.ecs-cluster.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gateway-2.id}"
  }

  tags {
    Name = "private-route-table-2"
  }
}

resource "aws_route_table_association" "private-subnet-2" {
  subnet_id      = "${aws_subnet.private-subnet-2.id}"
  route_table_id = "${aws_route_table.private-2.id}"
}
