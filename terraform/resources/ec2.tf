# 기존 IAM Role을 데이터로 가져오기
data "aws_iam_role" "ssm_role" {
  name = "ssm_role"
}
# IAM Instance Profile 선언
resource "aws_iam_instance_profile" "cozy_ec2_profile" {
  name = "cozy-ec2-profile"
  role = "ssm_role"  # 이미 존재하는 ssm_role을 참조
}

# Security group for CICD EC2 instances
resource "aws_security_group" "cozy_cicd_ec2_sg" {
  name        = "cozy-cicd-ec2-sg"
  description = "Security group for CICD EC2 instances"
  vpc_id      = aws_vpc.cozy_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.cozy_public_subnet_a.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name    = "cozy-cicd-ec2-sg"
    Creator = "cozy"
  }
}


# EC2 Jenkins instance
resource "aws_instance" "cozy-jenkins" {
  ami                    = "ami-0c8dc4d24f067f43d"
  instance_type          = "t3.small"
  key_name               = "cozy-key"
  subnet_id              = aws_subnet.cozy_private_subnet_a.id
  vpc_security_group_ids = [aws_security_group.cozy_cicd_ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.cozy_ec2_profile.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = "cozy-jenkins"
    Creator = "cozy"
  }
}

# EC2 GitLab instance
resource "aws_instance" "cozy-gitlab" {
  ami                    = "ami-0ea824b857e791495"
  instance_type          = "t3.large"
  key_name               = "cozy-key"
  subnet_id              = aws_subnet.cozy_private_subnet_a.id
  vpc_security_group_ids = [aws_security_group.cozy_cicd_ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.cozy_ec2_profile.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = "cozy-gitlab"
    Creator = "cozy"
  }
}
