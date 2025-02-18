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
