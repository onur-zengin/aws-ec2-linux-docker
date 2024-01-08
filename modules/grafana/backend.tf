terraform {
  backend "s3" {
    #bucket        = "tfstate-vmon" # moved to ansible playbook to ensure global uniqueness via epoch timestamp
    #region        = "eu-central-1" # moved to ansible playbook since terraform backend configuration doesn't accept variables
    key            = "global/grafana/vmon.tfstate"
    dynamodb_table = "tfstate-lock-vmon"
    encrypt        = true
  }
}
