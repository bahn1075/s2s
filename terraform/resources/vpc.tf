# S3 버킷 생성 (Terraform 상태 파일 저장용)
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "cozy-terraform-state-bucket"

  tags = {
    Name    = "cozy-terraform-state-bucket"
    Creator = "cozy"
  }
}


resource "aws_vpc" "cozy_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "cozy-vpc"
    Creator = "cozy"
  }
}

resource "aws_internet_gateway" "cozy_igw" {
  vpc_id = aws_vpc.cozy_vpc.id
  tags = {
    Name    = "cozy-igw"
    Creator = "cozy"
  }
}

resource "aws_nat_gateway" "cozy_nat_gateway" {
  allocation_id = aws_eip.cozy_nat_eip.id
  subnet_id     = aws_subnet.cozy_public_subnet_a.id
  tags = {
    Name    = "cozy-nat-gateway"
    Creator = "cozy"
  }
}

resource "aws_eip" "cozy_nat_eip" {
  associate_with_private_ip = true
  tags = {
    Name    = "cozy-nat-eip"
    Creator = "cozy"
  }
}

resource "aws_route_table" "cozy_public_route_table" {
  vpc_id = aws_vpc.cozy_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cozy_igw.id
  }
  tags = {
    Name    = "cozy-public-route-table"
    Creator = "cozy"
  }
}

resource "aws_route_table_association" "cozy_public_route_table_association_a" {
  subnet_id      = aws_subnet.cozy_public_subnet_a.id
  route_table_id = aws_route_table.cozy_public_route_table.id
}

resource "aws_route_table_association" "cozy_public_route_table_association_b" {
  subnet_id      = aws_subnet.cozy_public_subnet_b.id
  route_table_id = aws_route_table.cozy_public_route_table.id
}

resource "aws_route_table" "cozy_private_route_table" {
  vpc_id = aws_vpc.cozy_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cozy_nat_gateway.id
  }
  tags = {
    Name    = "cozy-private-route-table"
    Creator = "cozy"
  }
}

resource "aws_route_table_association" "cozy_private_route_table_association_a" {
  subnet_id      = aws_subnet.cozy_private_subnet_a.id
  route_table_id = aws_route_table.cozy_private_route_table.id
}

resource "aws_route_table_association" "cozy_private_route_table_association_b" {
  subnet_id      = aws_subnet.cozy_private_subnet_b.id
  route_table_id = aws_route_table.cozy_private_route_table.id
}

resource "aws_subnet" "cozy_public_subnet_a" {
  vpc_id                 = aws_vpc.cozy_vpc.id
  cidr_block             = "10.0.1.0/24"
  availability_zone      = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "cozy-public-subnet-a"
    Creator = "cozy"
  }
}

resource "aws_subnet" "cozy_public_subnet_b" {
  vpc_id                 = aws_vpc.cozy_vpc.id
  cidr_block             = "10.0.2.0/24"
  availability_zone      = "ap-northeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Name    = "cozy-public-subnet-b"
    Creator = "cozy"
  }
}

resource "aws_subnet" "cozy_private_subnet_a" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name    = "cozy-private-subnet-a"
    Creator = "cozy"
  }
}

resource "aws_subnet" "cozy_private_subnet_b" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name    = "cozy-private-subnet-b"
    Creator = "cozy"
  }
}

resource "aws_instance" "cozy-bastion" {
  ami                    = "ami-0aa4e2be59309ae9d"
  instance_type          = "t2.micro"
  key_name               = "cozy-key"
  subnet_id              = aws_subnet.cozy_public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.cozy_vpc_sg.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = "cozy-bastion"
    Creator = "cozy"
  }
}

resource "aws_ec2_instance_connect_endpoint" "cozy_instance_connect_endpoint" {
  subnet_id         = aws_subnet.cozy_private_subnet_a.id
  security_group_ids = [aws_security_group.cozy_vpc_sg.id]
  tags = {
    Name    = "cozy-instance-connect-endpoint"
    Creator = "cozy"
  }
}

resource "aws_security_group" "cozy_vpc_sg" {
  name        = "cozy-vpc-sg"
  description = "Security group for cozy VPC"
  vpc_id      = aws_vpc.cozy_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = {
    Name    = "cozy-vpc-sg"
    Creator = "cozy"
  }
}