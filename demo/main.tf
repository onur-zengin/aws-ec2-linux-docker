data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*-x86_64-gp2"]
  }
}


resource "aws_instance" "ne" {
  count           = var.instance_count
  instance_type   = var.instance_type
  ami             = data.aws_ami.linux.id
  user_data       = file("./demo/bootstrap.sh")
  security_groups = [aws_security_group.ne_inbound.name]

  tags = {
    Name = "${var.prefix}"
  }
}

resource "aws_eip" "ne_staticIP" {
  count = var.instance_count
}

resource "aws_eip_association" "eip_assoc" {
  count = var.instance_count
  instance_id = aws_instance.ne[count.index].id
  allocation_id = aws_eip.ne_staticIP[count.index].id
}



resource "aws_security_group" "ne_inbound" {
  description = var.sg_rule_description

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.sg_allowed_ranges
  }

  ingress {
    from_port   = 8080
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = var.sg_allowed_ranges
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.sg_allowed_ranges
  }
}

