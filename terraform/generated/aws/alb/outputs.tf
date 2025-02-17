output "aws_lb_target_group_tfer--cozy-gitlab-80-tg_id" {
  value = "${aws_lb_target_group.tfer--cozy-gitlab-80-tg.id}"
}

output "aws_lb_target_group_tfer--cozy-jenkins-8080-tg_id" {
  value = "${aws_lb_target_group.tfer--cozy-jenkins-8080-tg.id}"
}

output "aws_lb_tfer--cozy-alb-tf_id" {
  value = "${aws_lb.tfer--cozy-alb-tf.id}"
}
