data "aws_region" "current" {}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*-x86_64-gp2"]
  }
}


resource "aws_instance" "demo" {
  count           = var.instance_count
  instance_type   = var.instance_type
  ami             = data.aws_ami.linux.id
  key_name        = aws_key_pair.demo_key_pair.key_name
  user_data       = file("./demo/bootstrap.sh")
  security_groups = [aws_security_group.ne_inbound[0].name]

  tags = {
    Name = "${var.prefix}_${count.index}"
  }
}


resource "aws_eip" "ne_staticIP" {
  count = var.instance_count

  tags = {
    Name = "${var.prefix}_${count.index}"
  }
}


resource "aws_eip_association" "eip_assoc" {
  count         = var.instance_count
  instance_id   = aws_instance.demo[count.index].id
  allocation_id = aws_eip.ne_staticIP[count.index].id
}


resource "aws_route53_record" "nyc" {
  count   = var.instance_count
  zone_id = var.zone_id
  name    = "${var.city_code}.${count.index}.demo.oz-enterprises.co.uk"
  type    = "A"
  ttl     = 300
  records = [aws_eip.ne_staticIP[count.index].public_ip]
}


resource "aws_key_pair" "demo_key_pair" {
  key_name   = "demo_linux"
  public_key = file("./keys/demo_linux.pub")

  tags = {
    Name = "${var.prefix}"
  }
}


resource "aws_security_group" "ne_inbound" {
  count       = (var.instance_count == 0 ? 0 : 1) # Avoid orphan SGs being created in demo regions with no EC2 present
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
}
