##      For demo purposes only      ##
## Not to be deployed in production ##

locals {
  instance_count = (var.demo == false ? 0 : var.demo_instance_count)
}

resource "aws_route53_zone" "demo_dns_zone" {
  name          = var.demo_dns_zone
  force_destroy = false
}

resource "aws_route53_record" "demo_dns_record-web" {
  zone_id = aws_route53_zone.demo_dns_zone.zone_id
  name    = var.demo_dns_record-web
  type    = "A"
  ttl     = 300
  records = [aws_eip.staticIP.public_ip]
}

resource "aws_route53_record" "demo_dns_record-collector" {
  zone_id = aws_route53_zone.demo_dns_zone.zone_id
  name    = var.demo_dns_record-collector
  type    = "A"
  ttl     = 300
  records = [aws_eip.staticIP.public_ip]
}

resource "aws_route53_record" "demo_dns_record-certbot_challenge" {
  zone_id = aws_route53_zone.demo_dns_zone.zone_id
  name    = var.demo_dns_record-certbot_challenge
  type    = "TXT"
  ttl     = 300
  records = [aws_eip.staticIP.public_ip]
}

module "london" {
  city_code      = "lon"
  source         = "./demo"
  zone           = aws_route53_zone.demo_dns_zone
  instance_count = local.instance_count
  instance_type  = "t3.nano"
  providers = {
    aws = aws.eu-west-2
  }
}
/*
module "frankfurt" {
  city_code      = "fra"
  source         = "./demo"
  zone_id        = aws_route53_zone.demo_dns_zone.zone_id
  instance_count = local.instance_count
  providers = {
    aws = aws
  }
}

module "san_fran" {
  city_code      = "sfc"
  source         = "./demo"
  zone_id        = aws_route53_zone.demo_dns_zone.zone_id
  instance_count = local.instance_count
  providers = {
    aws = aws.us-west-1
  }
}

module "new_york" {
  city_code      = "nyc"
  source         = "./demo"
  zone_id        = aws_route53_zone.demo_dns_zone.zone_id
  instance_count = local.instance_count
  providers = {
    aws = aws.us-east-1
  }
}
*/
