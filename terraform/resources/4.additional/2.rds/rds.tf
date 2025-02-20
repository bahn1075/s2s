# VPC를 참조
data "aws_vpc" "cozy_vpc" {
  filter {
    name   = "tag:Name"
    values = ["cozy-vpc"]
  }
}

# 새로 생성한 프라이빗 서브넷을 참조
data "aws_subnet" "cozy_private_subnet_a2" {
  filter {
    name   = "tag:Name"
    values = ["cozy-private-subnet-a2"]
  }
}

data "aws_subnet" "cozy_private_subnet_b2" {
  filter {
    name   = "tag:Name"
    values = ["cozy-private-subnet-b2"]
  }
}

# RDS 보안 그룹 생성
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = data.aws_vpc.cozy_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # VPC CIDR 블록
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# RDS 서브넷 그룹 생성
resource "aws_db_subnet_group" "cozy_rds_subnet_group" {
  name       = "cozy-rds-subnet-group"
  subnet_ids = [data.aws_subnet.cozy_private_subnet_a2.id, data.aws_subnet.cozy_private_subnet_b2.id]

  tags = {
    Name = "cozy-rds-subnet-group"
  }
}

# RDS 인스턴스 생성
resource "aws_db_instance" "cozy_rds_instance" {
  identifier              = "cozy-rds-instance" # 이 부분이 DB 이름이 됰
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = "cozy_mysql_rds"
  username                = "admin"
  password                = "password123"
  db_subnet_group_name    = aws_db_subnet_group.cozy_rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true

  tags = {
    Name = "cozy-rds-instance"
  }
}