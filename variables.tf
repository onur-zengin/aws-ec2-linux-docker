variable "region" {
  description = "Prometheus & Grafana host region"
  type    = string
}

variable "instance_type" {
  description = "Host VM instance type"
  # t2.micro is free-tier eligible
  type    = string
  default = "t2.micro"
}

variable "ubuntu_release" {
  description = "Ubuntu release for the host instance"
  # major release changes should be bound to UAT
  type    = string
  default = "jammy-22"
}

variable "prefix" {
  description = "Name prefix for ease of resource identification on the AWS console"
  type        = string
  default     = "vmon"
}

variable "sg_rule_description" {
  type    = string
  default = "restrict_inbound"
}

variable "sg_allowed_ports" {
  type    = list(number)
  #default = [22, 80, 443, 9100]
  default = [22, 80, 443]
}

variable "sg_allowed_ranges" {
  description = "The IP ranges from which both Grafana & Prometheus web interfaces can be accessed."
  # This can be updated to include corporate IP ranges for internal-only use.
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "meta_bucket" {
  description = "Name of the S3 bucket where Grafana image & config files are stored"
  type    = string
}