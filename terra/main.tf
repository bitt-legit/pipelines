
export TF_VAR_ssn="123-45-6789"
export TF_VAR_passwd="W#LCOM#123456!$%&"

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "fb_data_nodes" {
  count             = var.fb_data_node_count
  ami               = data.aws_ami.amazon_linux_2.id
  instance_type     = var.fb_data_node_type
  key_name          = aws_key_pair.molecula.key_name
  security_groups   = [aws_security_group.featurebase.id]
  monitoring        = false
  associate_public_ip_address = true
  subnet_id         = var.subnet != "" ? var.subnet : module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]
  availability_zone = var.zone != "" ? var.zone : var.azs[count.index % length(var.azs)]

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = var.fb_data_disk_type
    volume_size = var.fb_data_disk_size_gb
    iops        = var.fb_data_disk_iops
  }

  tags = {
    Name = "${var.company_prefix}-featurebase-data-${count.index}"
  }
}


resource "aws_key_pair" "molecula" {
  key_name   = "se_token1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgQSMOfGxmFTMmRAVvNS61q4kK8S8ZrzmQcLeCdttPq2mIDUtSWkJkETh0jB7nkIiy6kku5pf4rm9NR+DithsqbdoptWeyB682SGeb5Du5GfrOhCh2Kz12u2VUlxkfDdGu1BrlKB9XRHALtSPBljdl0MZLcI8Ka7DPlCHiZssVNeWENJixCrdYxlK7eh28BpIeykEfXAOqzpk27IhYb62OYW9TgfeFoH1bg95pyhtC/cohidEmIHbpjDFyA08DiSFA4B6Bhv/V4X8LhoIg5NkggO76D6OMqouQsF0Vh1+HQV2GHgagwDA282OmmJ4QFcLttos7igQhTs2s2Gn59XdT garrett.raska"
}

resource "aws_security_group" "featurebase" {
  name        = "allow_featurebase"
  description = "Allow featurebase inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "UI from External"
    from_port        = 10101
    to_port          = 10101
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "GRPC from Internal"
    from_port        = 20101
    to_port          = 20101
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description      = "PostgreSQL from Internal"
    from_port        = 55432
    to_port          = 55432
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description      = "etcd from internal"
    from_port        = 10301
    to_port          = 10301
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description      = "etcd from internal 2"
    from_port        = 10401
    to_port          = 10401
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Any"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_featurebase"
  }
}

