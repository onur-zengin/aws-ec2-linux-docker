output "prometheus_host_address" {
  value = aws_instance.ec2.public_ip
}

output "grafana_auth" {
  value     = data.aws_secretsmanager_secret_version.latest
  sensitive = true
}