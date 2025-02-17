resource "aws_security_group" "cozy-alb-sg" {
  description = "for-alb"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    protocol    = "tcp"
    self        = "false"
    to_port     = "80"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8080"
    protocol    = "tcp"
    self        = "false"
    to_port     = "8080"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    protocol    = "tcp"
    self        = "false"
    to_port     = "80"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8080"
    protocol    = "tcp"
    self        = "false"
    to_port     = "8080"
  }

  name = "cozy-alb-sg"

  tags = {
    Creator = "cozy"
  }

  tags_all = {
    Creator = "cozy"
  }

  vpc_id = "vpc-0c5a09a03e82a45cc"
}

resource "aws_security_group" "cozy-bastion-sg" {
  description = "bastion-only-sg"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["165.243.5.20/32", "221.151.171.122/32", "27.122.140.10/32"]
    from_port   = "22"
    protocol    = "tcp"
    self        = "false"
    to_port     = "22"
  }

  name = "cozy-bastion-sg"

  tags = {
    Creator = "cozy"
    Name    = "cozy-to-bastion"
  }

  tags_all = {
    Creator = "cozy"
    Name    = "cozy-to-bastion"
  }

  vpc_id = "vpc-0c5a09a03e82a45cc"
}

resource "aws_security_group" "cozy-from-bastion_sg" {
  description = "from-bastion"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    protocol    = "tcp"
    self        = "false"
    to_port     = "80"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8080"
    protocol    = "tcp"
    self        = "false"
    to_port     = "8080"
  }

  ingress {
    cidr_blocks = ["10.0.0.108/32"]
    from_port   = "22"
    protocol    = "tcp"
    self        = "false"
    to_port     = "22"
  }

  name = "cozy-from-bastion"

  tags = {
    Creator = "cozy"
  }

  tags_all = {
    Creator = "cozy"
  }

  vpc_id = "vpc-0c5a09a03e82a45cc"
}

resource "aws_security_group" "eks-cluster-sg-cozy-eks-cluster-tf-456316359_sg-0ca3c2a6aa3d26c63" {
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    from_port = "0"
    protocol  = "-1"
    self      = "true"
    to_port   = "0"
  }

  name = "eks-cluster-sg-cozy-eks-cluster-tf-456316359"

  tags = {
    Creator                                     = "cozy"
    Name                                        = "eks-cluster-sg-cozy-eks-cluster-tf-456316359"
    "kubernetes.io/cluster/cozy-eks-cluster-tf" = "owned"
  }

  tags_all = {
    Creator                                     = "cozy"
    Name                                        = "eks-cluster-sg-cozy-eks-cluster-tf-456316359"
    "kubernetes.io/cluster/cozy-eks-cluster-tf" = "owned"
  }

  vpc_id = "vpc-0c5a09a03e82a45cc"
}
