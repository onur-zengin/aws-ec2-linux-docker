variable "region" {
  description = "Prometheus & Grafana host region"
  # Default Frankfurt, Germany.
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Host VM instance type"
  # t2.micro is free-tier eligible
  type    = string
  default = "t2.micro" 
}

variable "prefix" {
  description = "Name prefix for ease of resource identification on the AWS console"
  type        = string
  default     = "vmon"
}

variable "sg_rule_description" {
  type    = string
  default = "allow_inbound"
}

variable "sg_allowed_ports" {
  type    = list(number)
  default = [22, 80, 443, 9100, 9122]
}

variable "sg_allowed_ranges" {
  description = "The IP ranges from which both Grafana & Prometheus web interfaces can be accessed."
  # This can be updated to include corporate IP ranges for internal-only use.
  type        = list(string)
  default     = ["0.0.0.0/0"]
}



##      For demo purposes only      ##
## Not to be deployed in production ##

variable "demo" {
  description = "Creates demo EC2 instances in a variety of regions listed in the demo.tf file."
  # Leave default (false) in Production.
  type        = bool
  default     = true
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