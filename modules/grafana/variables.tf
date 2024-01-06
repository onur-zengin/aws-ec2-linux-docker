variable "grafana_web" {
  description = "The URL under which the Grafana web interface resides"
  type        = string
  default     = "https://vmon.zenite.uk/graf"
}


variable "grafana_org" {
  description = "Organization (company) name to be displayed on the Grafana web interface"
  type        = string
  default     = "Company Name"
}


variable "content_bucket" {
  type    = string
}


variable "prefix" {
  description = "Name prefix for ease of resource identification on the AWS console"
  type        = string
  default     = "vmon"
}