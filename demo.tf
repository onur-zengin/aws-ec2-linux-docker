##      For demo purposes only      ##
## Not to be deployed in production ##

provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
}

module "frankfurt" {
  source = "./demo/ne_instances"
  providers = {
    aws = aws
  }
}

module "san_fran" {
  source = "./demo/ne_instances"
  providers = {
    aws = aws.us-west-1
  }
}

module "london" {
  source        = "./demo/ne_instances"
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