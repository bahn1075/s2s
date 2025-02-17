resource "aws_internet_gateway" "cozy-igw" {
    vpc_id = aws_vpc.cozy_vpc.id

    tags = {
        Name = "cozy-igw"
        Creator = "cozy"
    } 
  
}