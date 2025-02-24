provider "aws" {
  region = "ap-northeast-2" // 원하는 AWS 리전으로 변경하세요
}

resource "aws_ecr_repository" "cozy_jenkins_repo" {
  name = "cozy-jenkins-repo"

  tags = {
    creator = "cozy"
  }
}

output "repository_url" {
  value = aws_ecr_repository.cozy_jenkins_repo.repository_url
}