# Terraform 백엔드 설정
terraform {
  backend "s3" {
    bucket         = "cozy-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "cozy-terraform-lock-table"
    encrypt        = true
  }
}