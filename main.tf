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
    #values = ["al2023-ami-2023.*-x86_64"]                                      // It has improvements over amazon-linux-2 (e.g. kernel-6). However, on-prem support not yet announced.
  }
}


resource "aws_instance" "ec2" {
  #ami               = data.aws_ami.linux.id
  ami                         = "ami-06dd92ecc74fdfb36"
  availability_zone           = data.aws_availability_zones.available.names[0]  // Must be in the same AZ with the EBS volume
  instance_type               = var.instance_type
  user_data_base64            = data.cloudinit_config.config.rendered           // Boot logs under /var/log/cloud-init-output.log in case of issues
  user_data_replace_on_change = true                                            // In order to avoid EC2 becoming left in hanging state after in-flight changes to user_data
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  security_groups             = [aws_security_group.ec2_inbound.name]

  root_block_device {
    delete_on_termination = true
    volume_size           = 8

    tags = {
      Name = "${var.prefix}_system-disk" // aka. "root volume"
    }
  }

  #depends_on = [ aws_ebs_volume.ebs ]

  tags = {
    Name = "${var.prefix}"
  }
}


resource "aws_ebs_volume" "ebs" {
  availability_zone = data.aws_availability_zones.available.names[0]            // Must be in the same AZ with the EC2 instance
  size              = 16

  tags = {
    Name = "${var.prefix}_data-disk"
  }
}


resource "aws_volume_attachment" "ec2_ebs" {
  device_name                    = "/dev/sdf"                                   // Depending on the block device driver of the kernel, the device could be attached with a different name than you specified. For example, if you specify a device name of /dev/sdh, your device could be renamed /dev/xvdh.
  instance_id                    = aws_instance.ec2.id
  volume_id                      = aws_ebs_volume.ebs.id
  stop_instance_before_detaching = true                                         // Workaround to known issue #8602. https://github.com/hashicorp/terraform-provider-aws/pull/21144
}


resource "aws_eip" "staticIP" {
  instance = aws_instance.ec2.id
}


resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "aws_linux"
  public_key = file("./keys/aws_linux.pub")

  tags = {
    Name = "${var.prefix}"
  }
}


resource "aws_security_group" "ec2_inbound" {
  name        = "Allow inbound traffic"
  description = var.sg_rule_description

  dynamic "ingress" {
    iterator = port
    for_each = var.sg_allowed_ports
    content {
      from_port   = port.value                                                     // these two lines are defining a range, not the src & dst ports
      to_port     = port.value                                                     // set them the same to configure a single port
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


resource "aws_s3_bucket" "graf_config" {
  bucket        = "graf-config"
  force_destroy = true

  tags = {
    Name = "${var.prefix}"
  }
}


resource "aws_s3_object" "coordinates" {
  bucket = aws_s3_bucket.graf_config.id
  key    = "geo.json"
  source = "configs/geo.json"
}

/*
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.graf_config.id
  acl = "public-read"
}


resource "aws_s3_bucket_policy" "bucket_policy" {
    bucket = aws_s3_bucket.graf_config.id
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "PublicReadGetObject",
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.graf_config.id}",
          "arn:aws:s3:::${aws_s3_bucket.graf_config.id}/*"
        ]
      }
    ]
  })
}
*/