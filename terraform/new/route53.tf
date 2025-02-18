# Route 53 호스팅 영역 생성
resource "aws_route53_zone" "cozy_zone" {
  name = "cozy.tf-dunn.link"
}

# Route 53 레코드 생성 (Jenkins)
resource "aws_route53_record" "jenkins_record" {
  zone_id = aws_route53_zone.cozy_zone.zone_id
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
  zone_id = aws_route53_zone.cozy_zone.zone_id
  name    = "gitlab.cozy.tf-dunn.link"
  type    = "A"

  alias {
    name                   = aws_lb.cozy_alb.dns_name
    zone_id                = aws_lb.cozy_alb.zone_id
    evaluate_target_health = true
  }
}

# ACM 퍼블릭 인증서 요청
resource "aws_acm_certificate" "cozy_cert" {
  domain_name       = "cozy.tf-dunn.link"
  validation_method = "DNS"

  subject_alternative_names = [
    "jenkins.cozy.tf-dunn.link",
    "gitlab.cozy.tf-dunn.link"
  ]

  tags = {
    Name    = "cozy-cert"
    Creator = "cozy"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 레코드 생성 (ACM 인증서 검증)
resource "aws_route53_record" "cozy_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cozy_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.cozy_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cozy_cert_validation" {
  certificate_arn         = aws_acm_certificate.cozy_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cozy_cert_validation : record.fqdn]
}
