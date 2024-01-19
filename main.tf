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
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ubuntu_release}.*"] 
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


resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.linux.id
  availability_zone           = data.aws_availability_zones.available.names[0] # Must be in the same AZ with the EBS volume
  instance_type               = var.instance_type
  user_data_base64            = data.cloudinit_config.config.rendered # Boot logs under /var/log/cloud-init-output.log in case of issues
  user_data_replace_on_change = true                                  # In order to avoid EC2 becoming left in hanging state after in-flight changes to user_data
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_boto3.name
  security_groups             = [aws_security_group.ec2_inbound.name]

  root_block_device {
    delete_on_termination = true
    volume_size           = 8

    tags = {
      Name = "${var.prefix}_system-disk" // aka. "root volume"
    }
  }

  tags = {
    Name = "${var.prefix}"
  }
}


resource "aws_ebs_volume" "ebs" {
  availability_zone = data.aws_availability_zones.available.names[0] # Must be in the same AZ with the EC2 instance
  size              = 16

  tags = {
    Name = "${var.prefix}_data-disk"
  }
}


resource "aws_volume_attachment" "ec2_ebs" {
  device_name                    = "/dev/sdf" # Depending on the block device driver of the kernel, the device could be attached with a different name than you specified. For example, if you specify a device name of /dev/sdh, your device could be renamed /dev/xvdh.
  instance_id                    = aws_instance.ec2.id
  volume_id                      = aws_ebs_volume.ebs.id
  stop_instance_before_detaching = true # Workaround to known issue #8602 for terraform-provider-aws.
}


resource "aws_eip" "static_ip" {
  #instance = aws_instance.ec2.id
}


resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.static_ip.id
}


resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "aws_linux"
  public_key = file("./keys/aws_linux.pub")

  tags = {
    Name = "${var.prefix}"
  }
}


resource "aws_iam_role" "ec2_boto3" {
  name                = "ec2-getSecrets"
  assume_role_policy  = file("./policies/ec2_assumeRole.json")
  managed_policy_arns = [aws_iam_policy.get_secrets.arn]
}


resource "aws_iam_instance_profile" "ec2_boto3" {
  name = "ec2_boto3_profile"
  role = aws_iam_role.ec2_boto3.name
}


resource "aws_iam_policy" "get_secrets" {
  name   = "ec2_getSecrets_policy"
  policy = file("./policies/ec2_getSecrets.json")
}


resource "aws_security_group" "ec2_inbound" {
  name        = "Restrict inbound traffic"
  description = var.sg_rule_description

  dynamic "ingress" {
    iterator = port
    for_each = var.sg_allowed_ports
    content {
      from_port   = port.value # these two lines are defining a range, not the src & dst ports
      to_port     = port.value # set them the same to configure a single port
      protocol    = "tcp"
      cidr_blocks = var.sg_allowed_ranges
    }
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [ "${aws_eip.static_ip.public_ip}/32" ]
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

  depends_on = [ aws_eip.static_ip ]
}


resource "aws_s3_bucket" "meta_bucket" {
  bucket        = var.meta_bucket
  force_destroy = true

  tags = {
    Name = "${var.prefix}"
  }
}


resource "aws_s3_bucket_public_access_block" "off" {
  bucket = aws_s3_bucket.meta_bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.meta_bucket.id
  policy = file("./policies/s3_bucketPolicy.json")
  depends_on = [aws_s3_bucket_public_access_block.off]
}


resource "aws_s3_bucket_ownership_controls" "bucket_owner" {
  bucket = aws_s3_bucket.meta_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.off]
}


resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket     = aws_s3_bucket.meta_bucket.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.bucket_owner]
}


resource "aws_s3_bucket_cors_configuration" "meta_bucket" {
  bucket = aws_s3_bucket.meta_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}


resource "aws_s3_object" "coordinates" {
  bucket = aws_s3_bucket.meta_bucket.id
  key    = "geo.json"
  source = "./configs/grafana/geo.json"
}


resource "aws_s3_object" "base_logo" {
  bucket = aws_s3_bucket.meta_bucket.id
  key    = "base_logo.svg"
  source = "./images/logo_base.svg"
}


resource "aws_s3_object" "red_logo" {
  bucket = aws_s3_bucket.meta_bucket.id
  key    = "red_logo.svg"
  source = "./images/logo_alert.svg"
}