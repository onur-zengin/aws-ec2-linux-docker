variable "instance_count" {
  type        = number
}

variable "instance_type" {
  type    = string
  default = "t2.micro" // free-tier eligible
}

variable "prefix" {
  type    = string
  default = "NR_ne_instance"
}

variable "sg_rule_description" {
  type    = string
  default = "allow_inbound"
}

variable "sg_allowed_ports" {
  type    = list(number)
  default = [22, 443, 9090, 9100]
}

variable "sg_allowed_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

