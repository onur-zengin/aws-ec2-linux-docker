terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.7"
    }
  }
}


provider "aws" {
  region = "eu-central-1"
}


provider "grafana" {
  url  = var.grafana_web
  auth = "admin:${local.grafana_auth_pw["admin"]}"
}
