resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = format("%s-public-subnet", var.vpc_name)
    },
    var.tags
  )
}

resource "aws_subnet" "private_with_nat" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_with_nat_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(
    {
      Name = format("%s-private-with-nat-subnet", var.vpc_name)
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(
    {
      Name = format("%s-private-subnet", var.vpc_name)
    },
    var.tags
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = format("%s-internet-gateway", var.vpc_name)
    },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge(
    {
      Name = format("%s-nat-gateway", var.vpc_name)
    },
    var.tags
  )
}

resource "aws_eip" "nat" {
  vpc = true

  tags = merge(
    {
      Name = format("%s-nat-eip", var.vpc_name)
    },
    var.tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    {
      Name = format("%s-public-rt", var.vpc_name)
    },
    var.tags
  )
}

resource "aws_route_table" "private_with_nat" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(
    {
      Name = format("%s-private-with-nat-rt", var.vpc_name)
    },
    var.tags
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = format("%s-private-rt", var.vpc_name)
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_with_nat" {
  subnet_id      = aws_subnet.private_with_nat.id
  route_table_id = aws_route_table.private_with_nat.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "ssh_access" {
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = format("%s-ssh-sg", var.vpc_name)
    },
    var.tags
  )
}

