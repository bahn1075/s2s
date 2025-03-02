# 기존 VPC와 서브넷을 참조
data "aws_vpc" "cozy_vpc" {
  filter {
    name   = "tag:Name"
    values = ["cozy-vpc"]
  }
}

data "aws_subnet" "cozy_private_subnet_a" {
  filter {
    name   = "tag:Name"
    values = ["cozy-private-subnet-a"]
  }
}

data "aws_subnet" "cozy_private_subnet_b" {
  filter {
    name   = "tag:Name"
    values = ["cozy-private-subnet-b"]
  }
}

# EKS 클러스터 생성
resource "aws_eks_cluster" "cluster" {
  name     = "cozy-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn
  version  = "1.32"  # Kubernetes 버전 설정

  vpc_config {
    subnet_ids = [
      data.aws_subnet.cozy_private_subnet_a.id,
      data.aws_subnet.cozy_private_subnet_b.id
    ]
  }

  # 클러스터가 사용할 IAM 역할
  depends_on = [aws_iam_role.eks_role]
}

# EKS 클러스터용 IAM 역할
resource "aws_iam_role" "eks_role" {
  name = "cozy-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# EKS 클러스터에 필요한 IAM 정책 연결
resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# EKS 노드 그룹을 위한 IAM 역할
resource "aws_iam_role" "eks_node_role" {
  name = "cozy-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# EKS 노드 그룹에 필요한 IAM 정책 연결
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ec2_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# EKS 노드 그룹 생성
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "cozy-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    data.aws_subnet.cozy_private_subnet_a.id,
    data.aws_subnet.cozy_private_subnet_b.id
  ]
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  depends_on = [aws_eks_cluster.cluster]
}

output "eks_cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.cluster.arn
}
