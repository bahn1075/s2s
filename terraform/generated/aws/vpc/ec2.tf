# IAM role for ec2 instances
resource "aws_iam_instance_profile" "cozy_ec2_profile" {
  name = "cozy-ec2-profile"
  role = aws_iam_role.ssm_role.name
}

# EC2 bastion instance
resource "aws_instance" "cozy-bastion" {
  ami                    = "ami-0aa4e2be59309ae9d"
  instance_type          = "t2.micro"
  key_name               = "cozy-key"
  subnet_id              = aws_subnet.cozy_public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.cozy_bastion_sg.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = "cozy-bastion"
    Creator = "cozy"
  }
}

# EC2 Jenkins instance
resource "aws_instance" "cozy-jenkins" {
  ami                    = "ami-0c8dc4d24f067f43d"
  instance_type          = "t3.small"
  key_name               = "cozy-key"
  subnet_id              = aws_subnet.cozy_private_subnet_a.id
  vpc_security_group_ids = [aws_security_group.cozy-cicd-ec2-sg.id]

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
  vpc_security_group_ids = [aws_security_group.cozy-cicd-ec2-sg.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = "cozy-gitlab"
    Creator = "cozy"
  }
}