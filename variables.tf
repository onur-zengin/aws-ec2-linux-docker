variable "region" {
  description = "AWS host region for the Prometheus & Grafana deployment"
  type    = string
}

variable "instance_type" {
  description = "AWS EC2 instance type for the host VM"
  # t2.micro is free-tier eligible
  type    = string
  default = "t2.micro"
}

variable "prefix" {
  description = "Resource name prefix for ease of identification on the AWS console"
  type        = string
  default     = "vmon"
}

variable "ubuntu_release" {
  description = "Ubuntu release for the host instance"
  # Major release changes should be bound to regression testing. Note the dependencies inside bootstrap.tf file.
  type    = string
  default = "jammy-22"
}

variable "sg_rule_description" {
  type    = string
  default = "restrict_inbound"
}

variable "sg_allowed_ports" {
  type    = list(number)
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