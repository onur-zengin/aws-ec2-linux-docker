variable "region" {
  description = "Prometheus & Grafana host region"
  # Default Frankfurt, Germany.
  type    = string
  default = "eu-central-1"
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
  type    = list(string)
  default = ["0.0.0.0/0"]
}
