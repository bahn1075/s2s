# S3 버킷 생성 (Terraform 상태 파일 저장용)
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "cozy-terraform-state-bucket"

  versioning {
    enabled = true
  }

  tags = {
    Name    = "cozy-terraform-state-bucket"
    Creator = "cozy"
  }
}

# DynamoDB 테이블 생성 (Terraform 상태 잠금용)
resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "terraform-lock-table"
    Creator = "cozy"
  }
}
