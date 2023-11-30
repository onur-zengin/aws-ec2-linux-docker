variable "instance_count" {
  type = number
}

variable "instance_type" {
  type    = string
  default = "t2.micro" // free-tier eligible
}


variable "city_code" {
  type = string
}

variable "zone" {
  #type = map(string)
}

variable "prefix" {
  type    = string
  default = "vmmon_demo_instance"
}

variable "sg_rule_description" {
  type    = string
  default = "allow_inbound"
}

variable "sg_allowed_ports" {
  type    = list(number)
  default = [22, 443, 9100]
}

variable "sg_allowed_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

