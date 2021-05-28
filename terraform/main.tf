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

resource "aws_s3_bucket" "cloud-resume" {
  bucket = var.bucketname
  acl    = "public-read"
  #policy = file("policy.json")
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

resource "aws_s3_bucket_policy" "getobject" {
  bucket = aws_s3_bucket.cloud-resume.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "resume-bucket-policy"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.cloud-resume.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_object" "index" {
  depends_on   = [aws_s3_bucket.cloud-resume]
  bucket       = var.bucketname
  key          = "index.html"
  source       = "./index.html"
  acl          = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "error" {
  depends_on   = [aws_s3_bucket.cloud-resume]
  bucket       = var.bucketname
  key          = "error.html"
  source       = "./error.html"
  acl          = "public-read"
  content_type = "text/html"
}