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
  default = "vmon"
}

variable "sg_rule_description" {
  type    = string
  default = "allow"
}

variable "default_allowed_ports" {
  type    = list(number)
  default = [22]
}

variable "prometheus_host_address" {
  type    = string
}

variable "default_allowed_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

