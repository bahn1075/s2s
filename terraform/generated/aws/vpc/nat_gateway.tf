# EIP for NAT Gateway
resource "aws_eip" "cozy_nat_eip" {
  associate_with_private_ip = "private_ip"
  
    tags = {
        Name    = "cozy_nat_eip"
        Creator = "cozy"
    }
}

# NAT Gateway
resource "aws_nat_gateway" "cozy_nat_gateway" {
  allocation_id = aws_eip.cozy_nat_eip.id
  subnet_id     = aws_subnet.cozy_public_subnet_a.id

  tags = {
    Name    = "cozy_nat_gateway"
    Creator = "cozy"
  }
  
}