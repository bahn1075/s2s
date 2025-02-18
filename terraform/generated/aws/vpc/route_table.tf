resource "aws_route_table" "tfer--rtb-014335aa7f9b8dff8" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "cozy-igw"
  }

  tags = {
    Creator = "cozy"
    Name    = "cozy-public-rtb"
  }

  tags_all = {
    Creator = "cozy"
    Name    = "cozy-public-rtb"
  }

  vpc_id = "cozy-vpc"
}

resource "aws_route_table" "cozy-rtb" {
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "cozy_nat_gateway"
  }

  tags = {
    Creator = "cozy"
    Name    = "cozy-private-rtb"
  }

  tags_all = {
    Creator = "cozy"
    Name    = "cozy-private-rtb"
  }

  vpc_id = "cozy-vpc"
}
