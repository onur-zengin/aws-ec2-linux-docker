terraform {
  backend "s3" {
    #bucket        = "tfstate-vmon" # removed, to ensure global uniqueness via epoch timestamp in ansible playbook
    key            = "global/main/vmon.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfstate-lock-vmon"
    encrypt        = true
  }
}