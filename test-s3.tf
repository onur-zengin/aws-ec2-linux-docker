variable "prod_media_bucket" {
  type    = string
  default = "test-bucket-18nov20231200"
}

resource "aws_s3_object" "gazetteer_test" {
  bucket = aws_s3_bucket.prod_media.id
  key    = "geo.json"
  source = "configs/geo.json"
}

resource "aws_s3_object" "base_logo" {
  bucket = aws_s3_bucket.prod_media.id
  key    = "base_logo.svg"
  source = "images/logo_circle_base.svg"
}

resource "aws_s3_object" "red_logo" {
  bucket = aws_s3_bucket.prod_media.id
  key    = "red_logo.svg"
  source = "images/logo_circle_red.svg"
}

resource "aws_s3_bucket" "prod_media" {
  bucket        = var.prod_media_bucket
  force_destroy = true
}

resource "aws_s3_bucket_cors_configuration" "prod_media" {
  bucket = aws_s3_bucket.prod_media.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_acl" "prod_media" {
  bucket     = aws_s3_bucket.prod_media.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.prod_media.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_iam_user" "prod_media_bucket" {
  name = "prod-media-bucket"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.prod_media.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "prod_media_bucket" {
  bucket = aws_s3_bucket.prod_media.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.prod_media_bucket}",
          "arn:aws:s3:::${var.prod_media_bucket}/*"
        ]
      },
      {
        Sid       = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.prod_media_bucket}",
          "arn:aws:s3:::${var.prod_media_bucket}/*"
        ]
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.example]
}