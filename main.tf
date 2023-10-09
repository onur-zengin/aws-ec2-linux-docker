provider "aws" {
  region = var.region
}


data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}


data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*-x86_64-gp2"]
    #values = ["al2023-ami-2023.*-x86_64"] // It has improvements over amazon-linux-2 (e.g. kernel-6). However, on-prem support not yet announced.
  }
}


resource "aws_instance" "ec2" {
  ami               = data.aws_ami.linux.id
  availability_zone = data.aws_availability_zones.available.names[0] // Must be in the same AZ with the EBS volume
  instance_type     = var.instance
  #user_data        = file("./docker/bootstrap.sh") // Boot logs under /var/log/cloud-init-output.log in case of issues
  user_data_base64  = data.cloudinit_config.config.rendered
  ebs_block_device {
    device_name           = "/dev/xvda"
    delete_on_termination = true
    volume_size           = 8
    tags = {
      Name = "${var.prefix}_system-disk" // aka. "root volume"
    }
  }
  security_groups = [aws_security_group.ec2_inbound.name]

  tags = {
    Name = "${var.prefix}"
  }
}


resource "aws_eip" "staticIP" {
  instance = aws_instance.ec2.id
}


resource "aws_ebs_volume" "ebs" {
  availability_zone = data.aws_availability_zones.available.names[0] // Must be in the same AZ with the EC2 instance
  size              = 16

  tags = {
    Name = "${var.prefix}_data-disk"
  }
}


resource "aws_volume_attachment" "ec2_ebs" {
  device_name = "/dev/xvdh"
  instance_id = aws_instance.ec2.id
  volume_id   = aws_ebs_volume.ebs.id
}


resource "aws_security_group" "ec2_inbound" {
  name        = "Allow inbound traffic"
  description = var.sg_rule_description

  dynamic "ingress" {
    iterator = port
    for_each = var.sg_allowed_ports
    content {
      from_port   = port.value // these two lines are defining a range, not the src & dst ports
      to_port     = port.value // set them the same to configure a single port
      protocol    = "tcp"
      cidr_blocks = var.sg_allowed_ranges
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.sg_allowed_ranges
  }

  tags = {
    Name = var.sg_rule_description
  }
}
