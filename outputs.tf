output "grafana_auth" {
  value     = data.aws_secretsmanager_secret_version.latest
  sensitive = true
}