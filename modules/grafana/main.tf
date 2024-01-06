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


resource "grafana_organization" "org" {
  name = var.grafana_org
}


resource "grafana_data_source" "prometheus" {
  org_id = grafana_organization.org.org_id
  type                = "prometheus"
  name                = "DS_PROMETHEUS"
  url                 = "http://prometheus:9090/prom"
  basic_auth_enabled  = false
}

/*
resource "grafana_dashboard" "node_view" {
  org_id = grafana_organization.org.org_id
  config_json = file("../../configs/grafana/dashboard_ne.json")
  depends_on = [ grafana_data_source.prometheus ]
}

resource "grafana_dashboard" "world_map" {
  org_id = grafana_organization.org.org_id
  config_json = file("../../configs/grafana/dashboard_map.json")
  depends_on = [ grafana_data_source.prometheus ]
}
*/


resource "aws_s3_bucket" "content_bucket" {
  bucket        = var.content_bucket
  force_destroy = true

  tags = {
    Name = "${var.prefix}"
  }
}

resource "aws_s3_bucket_acl" "content_bucket" {
  bucket = aws_s3_bucket.content_bucket.id
  acl = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.content_bucket]
}


resource "aws_s3_bucket_ownership_controls" "content_bucket" {
  bucket = aws_s3_bucket.content_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.content_bucket]
}


resource "aws_s3_bucket_public_access_block" "content_bucket" {
  bucket = aws_s3_bucket.content_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "content_bucket" {
  bucket = aws_s3_bucket.content_bucket.id
  policy = file("./policies/s3_bucketPolicy.json")
  depends_on = [aws_s3_bucket_public_access_block.content_bucket]
}


resource "aws_s3_object" "coordinates" {
  bucket = aws_s3_bucket.content_bucket.id
  key    = "geo.json"
  source = "configs/grafana/geo.json"
}

resource "aws_s3_object" "base_logo" {
  bucket = aws_s3_bucket.content_bucket.id
  key    = "base_logo.svg"
  source = "images/logo_circle_base.svg"
}

resource "aws_s3_object" "red_logo" {
  bucket = aws_s3_bucket.content_bucket.id
  key    = "red_logo.svg"
  source = "images/logo_circle_red.svg"
}