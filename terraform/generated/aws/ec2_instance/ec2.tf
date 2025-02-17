resource "aws_instance" "cozy-rocky-jenkins-docker" {
  ami                         = "ami-0c8dc4d24f067f43d"
  associate_public_ip_address = "false"
  availability_zone           = "ap-northeast-2a"

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_core_count = "1"

  cpu_options {
    core_count       = "1"
    threads_per_core = "2"
  }

  cpu_threads_per_core = "2"

  credit_specification {
    cpu_credits = "unlimited"
  }

  disable_api_stop        = "false"
  disable_api_termination = "false"
  ebs_optimized           = "true"

  enclave_options {
    enabled = "false"
  }

  get_password_data                    = "false"
  hibernation                          = "false"
  iam_instance_profile                 = "ssm_role"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t3.small"
  ipv6_address_count                   = "0"
  key_name                             = "cozy-key"

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
    instance_metadata_tags      = "disabled"
  }

  monitoring                 = "false"
  placement_partition_number = "0"

  private_dns_name_options {
    enable_resource_name_dns_a_record    = "false"
    enable_resource_name_dns_aaaa_record = "false"
    hostname_type                        = "ip-name"
  }

  private_ip = "10.0.2.88"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "10"
    volume_type           = "gp2"
  }

  source_dest_check = "true"
  subnet_id         = "subnet-02313495582a7a017"

  tags = {
    Creator = "cozy"
    Name    = "cozy-rocky-jenkins-docker"
  }

  tags_all = {
    Creator = "cozy"
    Name    = "cozy-rocky-jenkins-docker"
  }

  tenancy                = "default"
  vpc_security_group_ids = ["sg-04cf780e0d002861a"]
}

resource "aws_instance" "cozy-rocky-gitlab-docker" {
  ami                         = "ami-0ea824b857e791495"
  associate_public_ip_address = "false"
  availability_zone           = "ap-northeast-2a"

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_core_count = "1"

  cpu_options {
    core_count       = "1"
    threads_per_core = "2"
  }

  cpu_threads_per_core = "2"

  credit_specification {
    cpu_credits = "unlimited"
  }

  disable_api_stop        = "false"
  disable_api_termination = "false"
  ebs_optimized           = "true"

  enclave_options {
    enabled = "false"
  }

  get_password_data                    = "false"
  hibernation                          = "false"
  iam_instance_profile                 = "ssm_role"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t3.large"
  ipv6_address_count                   = "0"
  key_name                             = "cozy-key"

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
    instance_metadata_tags      = "disabled"
  }

  monitoring                 = "false"
  placement_partition_number = "0"

  private_dns_name_options {
    enable_resource_name_dns_a_record    = "false"
    enable_resource_name_dns_aaaa_record = "false"
    hostname_type                        = "ip-name"
  }

  private_ip = "10.0.2.7"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "10"
    volume_type           = "gp2"
  }

  source_dest_check = "true"
  subnet_id         = "subnet-02313495582a7a017"

  tags = {
    Creator = "cozy"
    Name    = "cozy-rocky-gitlab-docker"
  }

  tags_all = {
    Creator = "cozy"
    Name    = "cozy-rocky-gitlab-docker"
  }

  tenancy                = "default"
  vpc_security_group_ids = ["sg-04cf780e0d002861a"]
}

resource "aws_instance" "cozy-bastion" {
  ami                         = "ami-0aa4e2be59309ae9d"
  associate_public_ip_address = "false"
  availability_zone           = "ap-northeast-2a"

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_core_count = "1"

  cpu_options {
    core_count       = "1"
    threads_per_core = "1"
  }

  cpu_threads_per_core = "1"

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_stop        = "false"
  disable_api_termination = "false"
  ebs_optimized           = "false"

  enclave_options {
    enabled = "false"
  }

  get_password_data                    = "false"
  hibernation                          = "false"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.micro"
  ipv6_address_count                   = "0"
  key_name                             = "cozy-key"

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = "2"
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }

  monitoring                 = "false"
  placement_partition_number = "0"

  private_dns_name_options {
    enable_resource_name_dns_a_record    = "false"
    enable_resource_name_dns_aaaa_record = "false"
    hostname_type                        = "ip-name"
  }

  private_ip = "10.0.0.108"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    iops                  = "3000"
    throughput            = "125"
    volume_size           = "8"
    volume_type           = "gp3"
  }

  source_dest_check = "true"
  subnet_id         = "subnet-0e7a7b58b2a81ef06"

  tags = {
    Creator = "cozy"
    Name    = "cozy-bastion"
  }

  tags_all = {
    Creator = "cozy"
    Name    = "cozy-bastion"
  }

  tenancy                = "default"
  vpc_security_group_ids = ["sg-0f90578f184508ea1"]
}