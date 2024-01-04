terraform {
  backend "s3" {
    bucket         = var.backend
    key            = "global/main/vmon.tfstate"
    region         = var.region
    dynamodb_table = "tfstate-lock-vmon"
    encrypt        = true
  }
}