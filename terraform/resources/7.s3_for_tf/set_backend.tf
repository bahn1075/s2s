
# Terraform 백엔드 설정
terraform {
  backend "s3" {
    bucket         = "cozy-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}