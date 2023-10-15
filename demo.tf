##      For demo purposes only      ##
## Not to be deployed in production ##

locals {
  instance_count = (var.demo == false ? 0 : var.demo_instance_count)
}

module "frankfurt" {
  source         = "./demo"
  instance_count = local.instance_count
  providers = {
    aws = aws
  }
}
/*
module "san_fran" {
  source = "./demo"
  instance_count = local.instance_count
  providers = {
    aws = aws.us-west-1
  }
}

module "london" {
  source        = "./demo"
  instance_count = local.instance_count
  instance_type = "t3.nano"
  providers = {
    aws = aws.eu-west-2
  }
}

output "ne_data" {
  value = [
    module.frankfurt, 
    module.san_fran,
    module.london
  ]
}
*/