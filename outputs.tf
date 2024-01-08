output "resource_prefix" {
  value = var.prefix
}


output "HOST_IP_ADDRESS" {
  value   = aws_eip.staticIP.public_ip
}


/*
output "grafana_auth" {
  value     = data.aws_secretsmanager_secret_version.latest
  sensitive = true
}
*/