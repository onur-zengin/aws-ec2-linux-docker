##      For demo purposes only      ##
## Not to be deployed in production ##


variable "demo" {
  description = "Creates demo DNS configuration & EC2 instances in a variety of regions as listed in the rest of this file."
  # Leave default (false) in Production.
  type    = bool
  default = true
}


locals {
  demo_dns_setup = (var.demo == false ? 0 : 1)
  instance_count = (var.demo == false ? 0 : var.demo_instance_count)
}


variable "demo_instance_count" {
  description = "Number of EC2 instances to be created in each region in a demo setup"
  type        = number
  default     = 1
}


variable "demo_dns_zone" {
  description = "The apex record with a zone file representing the collection of all records managed together by Terraform"
  type        = string
  default     = "zenite.uk"
}


variable "demo_dns_record-web" {
  description = "The domain record under which both Grafana & Prometheus web interfaces reside"
  type        = string
  default     = "vmon.zenite.uk"
}


variable "demo_dns_record-collector" {
  description = "The domain record used by Prometheus to scrape its own host"
  type        = string
  default     = "self.vmon.zenite.uk"
}


variable "demo_dns_record-certbot_challenge" {
  description = "The domain record used by Certbot for the DNS challenge"
  type        = string
  default     = "_acme-challenge.zenite.uk"
}


resource "aws_route53_zone" "demo_dns_zone" {
  count         = local.demo_dns_setup
  name          = var.demo_dns_zone
  force_destroy = false
}


resource "aws_route53_record" "demo_dns_record-web" {
  count   = local.demo_dns_setup
  zone_id = aws_route53_zone.demo_dns_zone[0].zone_id
  name    = var.demo_dns_record-web
  type    = "A"
  ttl     = 300
  records = [aws_eip.staticIP.public_ip]
}


resource "aws_route53_record" "demo_dns_record-collector" {
  count   = local.demo_dns_setup
  zone_id = aws_route53_zone.demo_dns_zone[0].zone_id
  name    = var.demo_dns_record-collector
  type    = "A"
  ttl     = 300
  records = [aws_eip.staticIP.public_ip]
}


resource "aws_route53_record" "demo_dns_record-certbot_challenge" {
  count   = local.demo_dns_setup
  zone_id = aws_route53_zone.demo_dns_zone[0].zone_id
  name    = var.demo_dns_record-certbot_challenge
  type    = "TXT"
  ttl     = 300
  records = [aws_eip.staticIP.public_ip]
}


module "london" {
  city_code               = "lon"
  source                  = "./modules/demo_ec2"
  zone                    = aws_route53_zone.demo_dns_zone
  instance_count          = local.instance_count
  instance_type           = "t3.nano"
  prometheus_host_address = aws_eip.staticIP.public_ip
  providers = {
    aws = aws.eu-west-2
  }
}

module "frankfurt" {
  city_code               = "fra"
  source                  = "./modules/demo_ec2"
  zone                    = aws_route53_zone.demo_dns_zone
  instance_count          = local.instance_count
  prometheus_host_address = aws_eip.staticIP.public_ip
  providers = {
    aws = aws.eu-central-1
  }
}

module "san_fran" {
  city_code               = "sfc"
  source                  = "./modules/demo_ec2"
  zone                    = aws_route53_zone.demo_dns_zone
  instance_count          = local.instance_count
  instance_type           = "t3.nano"
  prometheus_host_address = aws_eip.staticIP.public_ip
  providers = {
    aws = aws.us-west-1
  }
}

module "new_york" {
  city_code               = "nyc"
  source                  = "./modules/demo_ec2"
  zone                    = aws_route53_zone.demo_dns_zone
  instance_count          = local.instance_count
  prometheus_host_address = aws_eip.staticIP.public_ip
  providers = {
    aws = aws.us-east-1
  }
}

