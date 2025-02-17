provider "aws" {
  region = "ap-northeast-2"
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

resource "aws_iam_role" "cozy_ssm_role" {
  name = "cozy-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Creator = "cozy"
  }
}

resource "aws_iam_role_policy_attachment" "cozy_ssm_role_policy_attachment" {
  role       = aws_iam_role.cozy_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "cozy_ssm_instance_profile" {
  name = "cozy-ssm-instance-profile"
  role = aws_iam_role.cozy_ssm_role.name
  tags = {
    Creator = "cozy"
  }
}

resource "aws_vpc_endpoint" "cozy_ssm_endpoint" {
  vpc_id            = aws_vpc.cozy_vpc.id
  service_name      = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.cozy_private_subnet_a.id, aws_subnet.cozy_private_subnet_b.id]
  security_group_ids = [aws_security_group.cozy_vpc_sg.id]
  tags = {
    Name    = "cozy-ssm-endpoint"
    Creator = "cozy"
  }
}

resource "aws_vpc_endpoint" "cozy_ec2messages_endpoint" {
  vpc_id            = aws_vpc.cozy_vpc.id
  service_name      = "com.amazonaws.ap-northeast-2.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.cozy_private_subnet_a.id, aws_subnet.cozy_private_subnet_b.id]
  security_group_ids = [aws_security_group.cozy_vpc_sg.id]
  tags = {
    Name    = "cozy-ec2messages-endpoint"
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