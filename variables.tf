variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "instance" {
  type    = string
  default = "t2.micro" // free-tier eligible
}

variable "prefix" {
  type    = string
  default = "Netradar_VMmon"
}

variable "sg_rule_description" {
  type    = string
  default = "allow_ssh&https"
}

variable "sg_allowed_ports" {
  type    = list(number)
  default = [22, 443, 9090, 3000]
}

variable "sg_allowed_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
