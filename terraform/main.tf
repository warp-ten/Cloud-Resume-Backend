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