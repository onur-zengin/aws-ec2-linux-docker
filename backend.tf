terraform {
  backend "s3" {
    bucket         = "tfstate-vmon"
    key            = "global/main/vmon.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfstate-lock-vmon"
    encrypt        = true
  }
}