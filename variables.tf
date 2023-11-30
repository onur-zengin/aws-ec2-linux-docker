variable "region" {
  description = "Prometheus host region"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t2.small" // free-tier eligible
}

variable "prefix" {
  description = "Resource name prefix for ease of identification on the AWS console"
  type        = string
  default     = "nr-vmon"
}

variable "sg_rule_description" {
  type    = string
  default = "allow_inbound"
}

variable "sg_allowed_ports" {
  type    = list(number)
  default = [22, 80, 443, 9100]
}

variable "sg_allowed_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "demo" {
  description = "Creates demo EC2 instances in a variety of regions listed in the demo.tf file. Leave default (false) in Production"
  type        = bool
  default     = false
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
  description = "The domain record used by Prometheus to scrape its own host"
  type        = string
  default     = "_acme-challenge.zenite.uk"
}