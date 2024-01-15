# Referencing the global remote backend to extract grafana_auth & other local variables;

data "terraform_remote_state" "main" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    region = var.region
    key    = "global/main/vmon.tfstate"
  }
}


locals {
  #grafana_auth_pw = jsondecode(data.terraform_remote_state.main.outputs.grafana_auth.secret_string)
  #prefix = data.terraform_remote_state.main.outputs.resource_prefix
  host_ip_address = data.terraform_remote_state.main.outputs.HOST_IP_ADDRESS
  grafana_web = "http://${local.host_ip_address}/graf"
}


resource "grafana_organization" "org" {
  name = var.grafana_org
}


resource "grafana_data_source" "prometheus" {
  org_id = grafana_organization.org.org_id
  type                = "prometheus"
  name                = "DS_PROMETHEUS"
  url                 = "http://prometheus:9090/prom"
  basic_auth_enabled  = false
}

/*
resource "grafana_dashboard" "sys_charts" {
  org_id = grafana_organization.org.org_id
  folder = grafana_folder.test.uid
  config_json = file("../../configs/grafana/dashboard_syscharts.json")
  depends_on = [ grafana_data_source.prometheus ]
}


resource "grafana_dashboard" "world_map" {
  org_id = grafana_organization.org.org_id
  folder = grafana_folder.test.uid
  config_json = file("../../configs/grafana/dashboard_worldmap.json")
  depends_on = [ grafana_data_source.prometheus ]
}
*/

resource "aws_s3_bucket" "content_bucket" {
  bucket        = var.content_bucket
  force_destroy = true

  tags = {
    Name = "${var.prefix}"
  }
}


#resource "aws_s3_bucket_policy" "content_bucket" {
#  bucket = aws_s3_bucket.content_bucket.id
#  policy = file("../../policies/s3_bucketPolicy.json")
#}


resource "aws_s3_object" "coordinates" {
  bucket = aws_s3_bucket.content_bucket.id
  key    = "geo.json"
  source = "../../configs/grafana/geo.json"
}


resource "aws_s3_object" "base_logo" {
  bucket = aws_s3_bucket.content_bucket.id
  key    = "base_logo.svg"
  source = "../../images/logo_circle_base.svg"
}


resource "aws_s3_object" "red_logo" {
  bucket = aws_s3_bucket.content_bucket.id
  key    = "red_logo.svg"
  source = "../../images/logo_circle_red.svg"
}