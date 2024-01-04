terraform {
  backend "s3" {
    #bucket = "tfstate-vmon-04012024"
    key            = "global/main/vmon.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfstate-lock-vmon"
    encrypt        = true
  }
}