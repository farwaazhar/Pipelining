terraform {
  required_version = ">= 1.4.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "farwa-terraform-website-123456"

  website {
    index_document = "index.html"
  }

  tags = {
    Name = "TerraformS3Website"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.public_access
  ]
}


resource "aws_s3_object" "index_file" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"
}
