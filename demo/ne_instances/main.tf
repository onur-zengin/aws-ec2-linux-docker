

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*-x86_64-gp2"]
    #values = ["al2023-ami-2023.*-x86_64"] // It has improvements over amazon-linux-2 (e.g. kernel-6). However, on-prem support not yet announced.
  }
}


resource "aws_instance" "ne" {
  ami           = data.aws_ami.linux.id
  instance_type = var.instance_type
  user_data        = file("./demo/ne_instances/bootstrap.sh") 
  security_groups = [aws_security_group.ne_inbound.name]

  tags = {
    Name = "${var.prefix}_ne"
  }
}

resource "aws_eip" "ne_staticIP" {
  instance = aws_instance.ne.id
}


resource "aws_security_group" "ne_inbound" {
  #name        = "Allow ne traffic"
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

