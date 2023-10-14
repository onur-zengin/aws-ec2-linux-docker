variable "region" {
  description = "Prometheus host region"
  type    = string
  default = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro" // free-tier eligible
}

variable "prefix" {
  description = "Resource name prefix for ease of identification on the AWS console"
  type    = string
  default = "NR_vmmon"
}

variable "sg_rule_description" {
  type    = string
  default = "allow_inbound"
}

variable "sg_allowed_ports" {
  type    = list(number)
  default = [22, 80, 443, 3000, 8080, 9090, 9100]
}

variable "sg_allowed_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "demo" {
  description = "Leave default (false) in Production"
  type = bool
  default = false
}

variable "demo_instance_count" {
  description = "Number of demo EC2 instances to be created in each NE region"
  type = number
  default = 1
}


