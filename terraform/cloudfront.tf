################
## CloudFront ##
################

resource "aws_cloudfront_distribution" "resume_dist" {
  origin {
    #S3 Static Website Domain
    domain_name = aws_s3_bucket.cloud-resume.bucket_regional_domain_name
    origin_id   = var.bucketname

    # You can use an OAI to restrict access to S3. This can be setup so that user can only 
    # access S3 files through the cloudfront distribution and not through the direct URL.
    # s3_origin_config {
    #   origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "resume-logs.s3.amazonaws.com"
#     prefix          = "resume"
#   }

  aliases = ["xaviercordovajr.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id   = var.bucketname
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Project = "resume"
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method = "sni-only"
  }
}

###############################
## Route53 Cloudfront Record ##
###############################

resource "aws_route53_record" "cloudfront" {
  zone_id = data.aws_route53_zone.resume.zone_id
  name = var.domain_name
  type = "A"

  alias {
    name    = aws_cloudfront_distribution.resume_dist.domain_name
    zone_id = aws_cloudfront_distribution.resume_dist.hosted_zone_id
    evaluate_target_health = false
  }
}   