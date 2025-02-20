# VPC를 참조
data "aws_vpc" "cozy_vpc" {
  filter {
    name   = "tag:Name"
    values = ["cozy-vpc"]
  }
}

# 새로운 프라이빗 서브넷 생성 (ap-northeast-2a)
resource "aws_subnet" "cozy_private_subnet_a" {
  vpc_id            = data.aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.5.0/24"  # 새로운 서브넷의 CIDR 블록
  availability_zone = "ap-northeast-2a"  # 가용 영역 A
  tags = {
    Name = "cozy-private-subnet-a2"
  }
}

# 새로운 프라이빗 서브넷 생성 (ap-northeast-2b)
resource "aws_subnet" "cozy_private_subnet_b" {
  vpc_id            = data.aws_vpc.cozy_vpc.id
  cidr_block        = "10.0.6.0/24"  # 새로운 서브넷의 CIDR 블록
  availability_zone = "ap-northeast-2b"  # 가용 영역 B
  tags = {
    Name = "cozy-private-subnet-b2"
  }
}