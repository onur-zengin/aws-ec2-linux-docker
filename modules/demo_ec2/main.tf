data "terraform_remote_state" "main" {
  
  backend = "s3"

  config = {
    bucket = "tfstate-vmon-04012024"
    key    = "global/main/vmon.tfstate"
    region = "eu-central-1"
  }
}

data "aws_region" "current" {}

data "aws_ami" "linux_amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*-x86_64-gp2"]
  }
}

data "aws_ami" "linux_ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.*"]                     # Major release upgrades should be bound to UAT, hence the version number is hardcoded (possible to configure as a variable).
  }
  filter {
    name   = "description"
    values = ["Canonical*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


locals {
  count = (var.instance_count == 0 ? 0 : 1) 
  #specific_allowed_ranges = data.terraform_remote_state.main.outputs.prometheus_host_address
  specific_allowed_ranges = ["${var.prometheus_host_address}/32"]
}


resource "aws_instance" "demo" {
  count                       = var.instance_count
  instance_type               = var.instance_type
  ami                         = data.aws_ami.linux_amzn2.id
  user_data_base64            = data.cloudinit_config.demo_config.rendered  # Boot logs under /var/log/cloud-init-output.log in case of issues
  user_data_replace_on_change = true                                        # In order to avoid EC2 getting left in hanging state after in-flight changes to user_data  
  key_name                    = aws_key_pair.demo_key_pair[0].key_name
  security_groups             = [aws_security_group.ne_inbound[0].name]

  tags = {
    Name = "${var.prefix}_${count.index}"
  }
}


resource "aws_eip" "ne_static_ip" {
  count = var.instance_count

  tags = {
    Name = "${var.prefix}_${count.index}"
  }
}


resource "aws_eip_association" "eip_assoc" {
  count         = var.instance_count
  instance_id   = aws_instance.demo[count.index].id
  allocation_id = aws_eip.ne_static_ip[count.index].id
}


resource "aws_route53_record" "a_record" {
  count   = var.instance_count
  zone_id = var.zone[0].zone_id
  name    = "${var.city_code}-${count.index}.${var.prefix}.${var.zone[0].name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.ne_static_ip[count.index].public_ip]
}


resource "aws_key_pair" "demo_key_pair" {
  count      = local.count                                                # Avoid orphan resources being created in demo regions with no EC2 present
  key_name   = "demo_linux"
  public_key = file("./keys/demo_linux.pub")

  tags = {
    Name = "${var.prefix}"
  }
}


resource "aws_security_group" "ne_inbound" {
  count      = local.count                                                # Avoid orphan resources being created in demo regions with no EC2 present
  description = var.sg_rule_description

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = local.specific_allowed_ranges
  }

  dynamic "ingress" {
    iterator = port
    for_each = var.default_allowed_ports
    content {
      from_port   = port.value                                            # these two lines are defining a range, not the src & dst ports
      to_port     = port.value                                            # set them the same to configure a single port
      protocol    = "tcp"
      cidr_blocks = var.default_allowed_ranges
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.default_allowed_ranges 
  }
}
