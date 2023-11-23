##      For demo purposes only      ##
## Not to be deployed in production ##

locals {
  instance_count = (var.demo == false ? 0 : var.demo_instance_count)
}

resource "aws_route53_zone" "zenite" {
  name          = "zenite.uk"
  force_destroy = false
}

resource "aws_route53_record" "demo" {
  zone_id = aws_route53_zone.zenite.zone_id
  name    = "demo.zenite.uk"
  type    = "A"
  ttl     = 300
  records = [aws_eip.staticIP.public_ip]
}

resource "aws_route53_zone" "oz_ent" {
  name          = "oz-enterprises.co.uk"
  force_destroy = false
}

resource "aws_route53_record" "demo_temp" {
  zone_id = aws_route53_zone.oz_ent.zone_id
  name    = "demo.oz-enterprises.co.uk"
  type    = "A"
  ttl     = 300
  records = [aws_eip.staticIP.public_ip]
}

resource "aws_route53_record" "self" {
  zone_id = aws_route53_zone.oz_ent.zone_id
  name    = "self.demo.oz-enterprises.co.uk"
  type    = "A"
  ttl     = 300
  records = [aws_eip.staticIP.public_ip]
}


module "london" {
  city_code      = "lon"
  source         = "./demo"
  zone_id        = aws_route53_zone.oz_ent.zone_id
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
  zone_id        = aws_route53_zone.oz_ent.zone_id
  instance_count = local.instance_count
  providers = {
    aws = aws
  }
}

module "san_fran" {
  city_code      = "sfc"
  source         = "./demo"
  zone_id        = aws_route53_zone.oz_ent.zone_id
  instance_count = local.instance_count
  providers = {
    aws = aws.us-west-1
  }
}

module "new_york" {
  city_code      = "nyc"
  source         = "./demo"
  zone_id        = aws_route53_zone.oz_ent.zone_id
  instance_count = local.instance_count
  providers = {
    aws = aws.us-east-1
  }
}
*/
