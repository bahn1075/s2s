resource "aws_security_group" "cozy-alb-sg" {
  description = "for-alb"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    self        = false
    to_port     = 443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    description = "gitlab port"
    self        = false
    to_port     = 80
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    protocol    = "tcp"
    description = "jenkins port"
    self        = false
    to_port     = 8080
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    self        = false
    to_port     = 443
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    description = "gitlab port"
    self        = false
    to_port     = 80
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    protocol    = "tcp"
    description = "jenkins port"
    self        = false
    to_port     = 8080
  }

  name = "cozy-alb-sg"

  tags = {
    Creator = "cozy"
  }

  vpc_id = aws_vpc.cozy_vpc.id
}

resource "aws_security_group" "cozy-bastion-sg" {
  description = "bastion-only-sg"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    self        = false
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["165.243.5.20/32", "221.151.171.122/32", "27.122.140.10/32"]
    from_port   = 22
    protocol    = "tcp"
    self        = false
    to_port     = 22
  }

  name = "cozy-bastion-sg"

  tags = {
    Creator = "cozy"
    Name    = "cozy-to-bastion"
  }

  vpc_id = aws_vpc.cozy_vpc.id
}

resource "aws_security_group" "cozy-cicd-ec2-sg" {
  description = "from-bastion"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    self        = false
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    self        = false
    to_port     = 443
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    self        = false
    to_port     = 80
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    protocol    = "tcp"
    self        = false
    to_port     = 8080
  }

  ingress {
    cidr_blocks = ["10.0.0.108/32"]
    from_port   = 22
    protocol    = "tcp"
    self        = false
    to_port     = 22
  }

  name = "cozy-from-bastion"

  tags = {
    Creator = "cozy"
  }

  vpc_id = aws_vpc.cozy_vpc.id
}

resource "aws_security_group" "cozy-eks-cluster-sg" {
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    self        = false
    to_port     = 0
  }

  ingress {
    from_port = 0
    protocol  = "-1"
    self      = true
    to_port   = 0
  }

  name = "cozy-eks-cluster-sg"

  tags = {
    Creator                                     = "cozy"
    Name                                        = "cozy-eks-cluster-sg"
    "kubernetes.io/cluster/cozy-eks-cluster"    = "owned"
  }

  vpc_id = aws_vpc.cozy_vpc.id
}
