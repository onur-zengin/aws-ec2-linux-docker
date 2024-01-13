output "HOST_IP_ADDRESS" {
  value   = aws_eip.static_ip.public_ip
}

/*
output "resource_prefix" {
  value = var.prefix
}

output "grafana_auth" {
  value     = data.aws_secretsmanager_secret_version.latest
  sensitive = true
}
*/