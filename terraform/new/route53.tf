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


# ec2 대상 그룹 생성
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
