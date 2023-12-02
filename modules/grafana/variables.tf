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