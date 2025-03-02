# S3 버킷 생성
resource "aws_s3_bucket" "cozy_bucket" {
  bucket = "cozy-s3-bucket"

  tags = {
    Name    = "cozy-s3-bucket"
    Creator = "cozy"
  }
}

# CloudFront Origin Access Identity 생성
resource "aws_cloudfront_origin_access_identity" "cozy_identity" {
  comment = "Cozy CloudFront Origin Access Identity"
}

# S3 버킷 정책 설정
resource "aws_s3_bucket_policy" "cozy_bucket_policy" {
  bucket = aws_s3_bucket.cozy_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.cozy_identity.iam_arn  # ARN 사용
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.cozy_bucket.arn}/*"
      }
    ]
  })
}

# CloudFront 배포 생성
resource "aws_cloudfront_distribution" "cozy_distribution" {
  origin {
    domain_name = aws_s3_bucket.cozy_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.cozy_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cozy_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cozy CloudFront Distribution"
  default_root_object = "index.html"

  aliases = ["cozy.tf-dunn.link"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS","PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.cozy_bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:151564769076:certificate/a9a6646f-9d74-40bc-b9be-ca9dabf6d4f9"
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name    = "cozy-distribution"
    Creator = "cozy"
  }
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.cozy_distribution.domain_name
}