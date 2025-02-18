# public subnet
resource "aws_subnet" "cozy_public_subnet_a" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name    = "cozy_public_subnet_a"
    Creator = "cozy"
  }
}

resource "aws_subnet" "cozy_public_subnet_b" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name    = "cozy_public_subnet_b"
    Creator = "cozy"
  }
}

# private subnet
resource "aws_subnet" "cozy_private_subnet_a" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name    = "cozy_private_subnet_a"
    Creator = "cozy"
  }
}

resource "aws_subnet" "cozy_private_subnet_b" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name    = "cozy_private_subnet_b"
    Creator = "cozy"
  }
}