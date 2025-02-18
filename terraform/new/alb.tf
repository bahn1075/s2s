# ALB 생성
resource "aws_lb" "cozy_alb" {
  name               = "cozy-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cozy_cicd_ec2_sg.id]
  subnets            = [aws_subnet.cozy_public_subnet_a.id, aws_subnet.cozy_public_subnet_b.id]

  tags = {
    Name    = "cozy-alb"
    Creator = "cozy"
  }
}

# Jenkins 대상 그룹 생성
resource "aws_lb_target_group" "cozy_jenkins_tg" {
  name     = "cozy-jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.cozy_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name    = "cozy-jenkins-tg"
    Creator = "cozy"
  }
}

resource "aws_lb_target_group_attachment" "cozy_jenkins_tg_attachment" {
  target_group_arn = aws_lb_target_group.cozy_jenkins_tg.arn
  target_id        = aws_instance.cozy-jenkins.id
  port             = 8080
}

# GitLab 대상 그룹 생성
resource "aws_lb_target_group" "cozy_gitlab_tg" {
  name     = "cozy-gitlab-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.cozy_vpc.id

  health_check {
    path                = "/login"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name    = "cozy-gitlab-tg"
    Creator = "cozy"
  }
}

resource "aws_lb_target_group_attachment" "cozy_gitlab_tg_attachment" {
  target_group_arn = aws_lb_target_group.cozy_gitlab_tg.arn
  target_id        = aws_instance.cozy-gitlab.id
  port             = 80
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

# ALB 리스너 생성 (HTTP)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.cozy_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cozy_jenkins_tg.arn
  }
}

# ALB 리스너 생성 (HTTPS)
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.cozy_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cozy_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cozy_gitlab_tg.arn
  }
}

# Jenkins 리스너 규칙 생성 (HTTPS)
resource "aws_lb_listener_rule" "jenkins_https_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cozy_jenkins_tg.arn
  }

  condition {
    host_header {
      values = ["jenkins.cozy.tf-dunn.link"]
    }
  }
}

# GitLab 리스너 규칙 생성 (HTTPS)
resource "aws_lb_listener_rule" "gitlab_https_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cozy_gitlab_tg.arn
  }

  condition {
    host_header {
      values = ["gitlab.cozy.tf-dunn.link"]
    }
  }
}

# Jenkins 리스너 규칙 생성 (HTTP)
resource "aws_lb_listener_rule" "jenkins_http_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cozy_jenkins_tg.arn
  }

  condition {
    path_pattern {
      values = ["/jenkins/*"]
    }
  }
}

# GitLab 리스너 규칙 생성 (HTTP)
resource "aws_lb_listener_rule" "gitlab_http_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cozy_gitlab_tg.arn
  }

  condition {
    path_pattern {
      values = ["/gitlab/*"]
    }
  }
}
