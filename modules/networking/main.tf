resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "central-1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "eu-central-1a"
  }
}
resource "aws_subnet" "central-1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "eu-central-1b"
  }
}
resource "aws_internet_gateway" "main" {}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main rt"
  }
}

resource "aws_route_table_association" "central-1b" {
  subnet_id = aws_subnet.central-1b.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "central-1a" {
  subnet_id = aws_subnet.central-1a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route" "internet" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.main.id
  gateway_id = aws_internet_gateway.main.id
}

