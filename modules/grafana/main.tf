# Referencing the global remote backend to extract grafana_auth;

locals {
  grafana_auth_pw = jsondecode(data.terraform_remote_state.main.outputs.grafana_auth.secret_string)
}


data "terraform_remote_state" "main" {
  
  backend = "s3"

  config = {
    bucket = "tfstate-vmon"
    key    = "global/main/vmon.tfstate"
    region = "eu-central-1"
  }
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
resource "grafana_dashboard" "node_view" {
  org_id = grafana_organization.org.org_id
  config_json = file("../../configs/grafana/dashboard_ne.json")
  depends_on = [ grafana_data_source.prometheus ]
}

resource "grafana_dashboard" "world_map" {
  org_id = grafana_organization.org.org_id
  config_json = file("../../configs/grafana/dashboard_map.json")
  depends_on = [ grafana_data_source.prometheus ]
}
*/


