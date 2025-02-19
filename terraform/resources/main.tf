provider "aws" {
  region = "ap-northeast-2"
}


resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB 테이블 생성 (Terraform 상태 잠금용)
resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = "cozy-terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "cozy-terraform-lock-table"
    Creator = "cozy"
  }
}
