terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

## Import Hosted Zone Data ##
data "aws_route53_zone" "resume" {
  name         = "xaviercordovajr.com."
  private_zone = false
}

## S3 Bucket Static Website ##
resource "aws_s3_bucket" "cloud-resume" {
  bucket        = var.bucketname
  acl           = "private"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  tags = {
    Name    = "Cloud-Resume"
    Project = "resume"
  }
}

## Bucket Policy ##
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cloud-resume.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.cloud-resume.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

## Block Public Access ##
resource "aws_s3_bucket_public_access_block" "block-public" {
  bucket = aws_s3_bucket.cloud-resume.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# ## Bucket Object Uploads ##
# resource "aws_s3_bucket_object" "index" {
#   depends_on   = [aws_s3_bucket.cloud-resume]
#   bucket       = var.bucketname
#   key          = "index.html"
#   source       = "../html/index.html"
# #  acl          = "public-read"
#   content_type = "text/html"
# }

# resource "aws_s3_bucket_object" "error" {
#   depends_on   = [aws_s3_bucket.cloud-resume]
#   bucket       = var.bucketname
#   key          = "error.html"
#   source       = "../html/error.html"
# #  acl          = "public-read"
#   content_type = "text/html"
# }

# resource "aws_s3_bucket_object" "gif" {
#   depends_on = [aws_s3_bucket.cloud-resume]
#   bucket     = var.bucketname
#   key        = "yellowranger.gif"
#   source     = "../html/yellowranger.gif"
#   #acl        = "public-read"
# }

## Dynamdb ##
resource "aws_dynamodb_table" "viewcount" {
  name           = "resume-view-count"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 4
  hash_key       = "count"

  attribute {
    name = "count"
    type = "S"
  }
}