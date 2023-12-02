resource "grafana_organization" "org" {
  name = var.grafana_org
}


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


resource "grafana_data_source" "prometheus" {
  org_id = grafana_organization.org.org_id
  type                = "prometheus"
  name                = "DS_PROMETHEUS"
  url                 = "http://prometheus:9090/prom"
  basic_auth_enabled  = false
}