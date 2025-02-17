provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "cozy_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "cozy-vpc"
  }
}

resource "aws_subnet" "cozy_public_subnet_a" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "cozy-public-subnet-a"
  }
}

resource "aws_subnet" "cozy_public_subnet_b" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "cozy-public-subnet-b"
  }
}

resource "aws_subnet" "cozy_private_subnet_a" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "cozy-private-subnet-a"
  }
}

resource "aws_subnet" "cozy_private_subnet_b" {
  vpc_id            = aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "cozy-private-subnet-b"
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
}

resource "aws_iam_role_policy_attachment" "cozy_ssm_role_policy_attachment" {
  role       = aws_iam_role.cozy_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "cozy_ssm_instance_profile" {
  name = "cozy-ssm-instance-profile"
  role = aws_iam_role.cozy_ssm_role.name
}

resource "aws_vpc_endpoint" "cozy_ssm_endpoint" {
  vpc_id       = aws_vpc.cozy_vpc.id
  service_name = "com.amazonaws.ap-northeast-2.ssm"
  subnet_ids   = [aws_subnet.cozy_private_subnet_a.id, aws_subnet.cozy_private_subnet_b.id]
  security_group_ids = [aws_security_group.cozy_vpc_sg.id]
  tags = {
    Name = "cozy-ssm-endpoint"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cozy-vpc-sg"
  }
}