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