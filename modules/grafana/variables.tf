variable "region" {
  description = "Prometheus & Grafana host region"
  type    = string
}


variable "content_bucket" {
  description = "Name of the S3 bucket where Grafana image & config files will be stored"
  type    = string
  default = "content-bucket-090909334"
}


variable "grafana_org" {
  description = "Organization name to be displayed on the Grafana web interface"
  type        = string
  default     = "Company X"
}


/*
variable "prefix" {
  description = "Name prefix for ease of resource identification on the AWS console"
  type        = string
  default     = "vmon"
}


variable "grafana_web" {
  description = "The URL under which the Grafana web interface resides"
  type        = string
  default     = "https://vmon.zenite.uk/graf"
}
*/