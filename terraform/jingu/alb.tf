# alb
resource "aws_lb" "jingu_alb" {
  name               = "s2s-jingu-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jingu_sg_alb.id]
  subnets            = [aws_subnet.jingu_public_subnet_a.id, aws_subnet.jingu_public_subnet_b.id]
 
  enable_deletion_protection = true
 
  tags = {
    Name = "s2s-jingu-alb-tf"
  }
}
 
resource "aws_alb_target_group" "jingu_tg_gitlab" {
  name     = "jingu-tg-gitlab-tf"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.jingu_vpc.id
 
  health_check {
    interval            = 30
    path                = "/users/sign_in"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
 
  tags = {
    Name = "jingu-tg-gitlab-tf"
  }
}
 
resource "aws_alb_target_group" "jingu_tg_jenkins" {
  name     = "jingu-tg-jenkins-tf"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.jingu_vpc.id
 
  health_check {
    interval            = 30
    path                = "/login"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
 
  tags = {
    Name = "jingu-tg-jenkins-tf"
  }
}
 
resource "aws_alb_target_group_attachment" "jingu_alb_tg_gitlab_attachment" {
  target_group_arn = aws_alb_target_group.jingu_tg_gitlab.arn
  target_id        = aws_instance.jingu_ec2_gitlab.id
  port             = 80
}
 
resource "aws_alb_target_group_attachment" "jingu_alb_tg_jenkins_attachment" {
  target_group_arn = aws_alb_target_group.jingu_tg_jenkins.arn
  target_id        = aws_instance.jingu_ec2_jenkins.id
  port             = 8080
}
 
# acm certificate
resource "aws_acm_certificate" "jingu_acm"   {
  domain_name  = "*.jingu.tf-dunn.link"
  validation_method = "DNS"
 
  validation_option {
    domain_name       = "*.jingu.tf-dunn.link"
    validation_domain = "jingu.tf-dunn.link"
  }
}
 
resource "aws_acm_certificate_validation" "jingu_acm_validation" {
  certificate_arn         = aws_acm_certificate.jingu_acm.arn
  validation_record_fqdns = [aws_route53_record.jingu_acm_record.fqdn]
}
 
# alb listener
resource "aws_alb_listener" "jingu_alb_listener_https" {
  load_balancer_arn = aws_lb.jingu_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.jingu_acm.arn
 
  default_action {
    target_group_arn = aws_alb_target_group.jingu_tg_jenkins.arn
    type             = "forward"
  }
}
 
resource "aws_alb_listener" "jingu_alb_listener_gitlab" {
  load_balancer_arn = aws_lb.jingu_alb.arn
  port              = 80
  protocol          = "HTTP"
 
  default_action {
    target_group_arn = aws_alb_target_group.jingu_tg_gitlab.arn
    type             = "forward"
  }
}
 
resource "aws_alb_listener" "jingu_alb_listener_jenkins" {
  load_balancer_arn = aws_lb.jingu_alb.arn
  port              = 8080
  protocol          = "HTTP"
 
  default_action {
    target_group_arn = aws_alb_target_group.jingu_tg_jenkins.arn
    type             = "forward"
  }
}
 
# alb listener rule
resource "aws_alb_listener_rule" "jingu_alb_listener_rule_https" {
  listener_arn = aws_alb_listener.jingu_alb_listener_https.arn
  priority     = 100
 
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.jingu_tg_gitlab.arn
  }
 
  condition {
    host_header {
      values = ["gitlab.jingu.tf-dunn.link"]
    }
  }
}
 
resource "aws_alb_listener_rule" "jingu_alb_listener_rule_gitlab" {
  listener_arn = aws_alb_listener.jingu_alb_listener_gitlab.arn
  priority     = 100
 
  action {
    type             = "redirect"
 
    redirect {
        port = "443"
        protocol = "HTTPS"
        host = "gitlab.jingu.tf-dunn.link"
        status_code = "HTTP_301"
    }
  }
 
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
 
resource "aws_alb_listener_rule" "jingu_alb_listener_rule_jenkins" {
  listener_arn = aws_alb_listener.jingu_alb_listener_jenkins.arn
  priority     = 100
 
  action {
    type             = "redirect"
 
    redirect {
        port = "443"
        protocol = "HTTPS"
        host = "jenkins.jingu.tf-dunn.link"
        status_code = "HTTP_301"
    }
  }
 
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
 
# route53
resource "aws_route53_zone" "jingu_hosting_zone" {
  name = "jingu.tf-dunn.link."
}
 
resource "aws_route53_record" "jingu_dns_gitlab" {
  zone_id = aws_route53_zone.jingu_hosting_zone.zone_id
  name    = "gitlab.jingu.tf-dunn.link"
  type    = "A"
 
  alias {
    name     = aws_lb.jingu_alb.dns_name
    zone_id  = aws_lb.jingu_alb.zone_id
    evaluate_target_health = true
  }
}
 
resource "aws_route53_record" "jingu_dns_jenkins" {
  zone_id = aws_route53_zone.jingu_hosting_zone.zone_id
  name    = "jenkins.jingu.tf-dunn.link"
  type    = "A"
 
  alias {
    name     = aws_lb.jingu_alb.dns_name
    zone_id  = aws_lb.jingu_alb.zone_id
    evaluate_target_health = true
  }
}
 
resource "aws_route53_record" "jingu_acm_record" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.jingu_acm.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.jingu_acm.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.jingu_acm.domain_validation_options)[0].resource_record_type
  zone_id         = aws_route53_zone.jingu_hosting_zone.zone_id
 
  ttl             = 60
}
 
resource "aws_route53_record" "jingu_root_hosting_zone_record" {
  allow_overwrite = true
  zone_id = "Z0125634M15R5UL5YG0F"
  name    = "jingu.tf-dunn.link"
  ttl     = 300
  type    = "NS"
 
  records = [
    aws_route53_zone.jingu_hosting_zone.name_servers[0],
    aws_route53_zone.jingu_hosting_zone.name_servers[1],
    aws_route53_zone.jingu_hosting_zone.name_servers[2],
    aws_route53_zone.jingu_hosting_zone.name_servers[3],
  ]
}