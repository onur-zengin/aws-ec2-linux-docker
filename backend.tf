locals {
  backend = var.backend
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = local.backend
    key            = "global/main/vmon.tfstate"
    region         = local.region
    dynamodb_table = "tfstate-lock-vmon"
    encrypt        = true
  }
}