## S3 - Static Website ##
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
    Provisioner = "terraform"
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