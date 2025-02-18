resource "aws_lb" "cozy-alb-tf" {
  client_keep_alive = "3600"
  enable_deletion_protection = true
  load_balancer_type                          = "application"
  name                                        = "cozy-alb-tf"
  preserve_host_header                        = "false"
  security_groups                             = ["sg-051eab0c7419e350a"]

  subnets = ["cozy-public-subnet-a", "cozy-public-subnet-b"]

  tags = {
    Creator = "cozy"
  }

  tags_all = {
    Creator = "cozy"
  }

}