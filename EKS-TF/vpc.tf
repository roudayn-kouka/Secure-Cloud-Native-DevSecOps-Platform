data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc-name]
  }
}

data "aws_internet_gateway" "igw" {
  filter {
    name   = "tag:Name"
    values = [var.igw-name]
  }
}

data "aws_subnet" "subnet" {
  filter {
    name   = "tag:Name"
    values = [var.subnet-name]
  }
}

data "aws_security_group" "sg-default" {
  filter {
    name   = "tag:Name"
    values = [var.security-group-name]
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id                  = data.aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                     = var.subnet-name2
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = data.aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.rt-name2
  }
}

resource "aws_route_table_association" "rt-association2" {
  route_table_id = aws_route_table.rt2.id
  subnet_id      = aws_subnet.public-subnet2.id
}

# ---------------------------------------------------------------------------
# Private networking: worker nodes and the database have no public IP.
# Outbound traffic (image pulls, updates) leaves through a NAT gateway.
# ---------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private-subnet-cidrs)
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = var.private-subnet-cidrs[count.index]
  availability_zone = var.availability-zones[count.index]

  tags = {
    Name                              = "${var.cluster-name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.cluster-name}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = data.aws_subnet.subnet.id # public subnet created by Jenkins-Server-TF
  tags          = { Name = "${var.cluster-name}-nat" }
}

resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.cluster-name}-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
