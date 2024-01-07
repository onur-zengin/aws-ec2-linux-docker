output "prometheus_host_address" {
  value   = aws_eip.staticIP.public_ip
}

/*
output "grafana_auth" {
  value     = data.aws_secretsmanager_secret_version.latest
  sensitive = true
}
*/