
resource "aws_s3_bucket" "terraform-state" {
  bucket = "cloudresume-state"
  acl    = "private"
  force_destroy = true
  # lifecycle {
  #   prevent_destroy = true
  # }
  tags = {
    Name    = "Terraform-Backend-CloudResume"
    Project = "resume"
  }
  versioning {
    enabled = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

## Block Public Access ##
resource "aws_s3_bucket_public_access_block" "state-block-public" {
  bucket = aws_s3_bucket.terraform-state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## Dynamodb for State Locking ##
# resource "aws_dynamodb_table" "terraform-locks" {
#   name         = "terraform-state-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Project = "resume"
#   }
# }

terraform {
  backend "s3" {
    bucket = "cloudresume-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
#    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }
}