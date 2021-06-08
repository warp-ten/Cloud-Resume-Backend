
resource "aws_s3_bucket" "terraform-state" {
  bucket = "cloudresume-state"
  acl    = "private"
  #Prevent the state from being destroy when a terraform destroy is run
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = "Terraform-Backend-CloudResume"
    Project = "resume"
  }

  # versioning {
  #   enabled = true
  # }

  # server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm = "AES256"
  #     }
  #   }
  # }

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
    bucket = "CloudResume-State"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}