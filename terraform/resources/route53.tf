# 신규 호스팅 영역 생성
resource "aws_route53_zone" "cozy_tf_dunn_link" {
  name = "cozy.tf-dunn.link"
}

# 기존 호스팅 영역 (tf-dunn.link)의 Zone ID를 가져오기 위해 사용
data "aws_route53_zone" "parent_zone" {
  name = "tf-dunn.link."
}

# 신규 호스팅 영역의 NS 레코드 값을 가져와 기존 호스팅 영역에 추가
resource "aws_route53_record" "ns_record_in_parent_zone" {
  zone_id = data.aws_route53_zone.parent_zone.id  # 기존 호스팅 영역의 Zone ID를 사용
  name    = "cozy.tf-dunn.link"  # 하위 도메인
  type    = "NS"
  ttl     = 86400  # 24시간
  records = aws_route53_zone.cozy_tf_dunn_link.name_servers  # 신규 호스팅 영역의 NS 레코드 값 자동 사용
}

# Route 53 레코드 생성 (Jenkins)
resource "aws_route53_record" "jenkins_record" {
  zone_id = aws_route53_zone.cozy_tf_dunn_link.zone_id
  name    = "jenkins.cozy.tf-dunn.link"
  type    = "A"

  alias {
    name                   = aws_lb.cozy_alb.dns_name
    zone_id                = aws_lb.cozy_alb.zone_id
    evaluate_target_health = true
  }
}

# Route 53 레코드 생성 (GitLab)
resource "aws_route53_record" "gitlab_record" {
  zone_id = aws_route53_zone.cozy_tf_dunn_link.zone_id
  name    = "gitlab.cozy.tf-dunn.link"
  type    = "A"

  alias {
    name                   = aws_lb.cozy_alb.dns_name
    zone_id                = aws_lb.cozy_alb.zone_id
    evaluate_target_health = true
  }
}

# Route 53 레코드 생성 (CloudFront)
resource "aws_route53_record" "cloudfront_record" {
  zone_id = aws_route53_zone.cozy_tf_dunn_link.zone_id
  name    = "cozy.tf-dunn.link"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cozy_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cozy_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
