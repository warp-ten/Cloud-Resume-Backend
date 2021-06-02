# output "Hostedzone-ns" {
#    value = "${data.aws_route53_zone.resume.name_servers}"
# }

output "S3-Endpoint" {
  value = aws_s3_bucket.cloud-resume.website_endpoint
}

output "Cloudfront-Domain" {
  value = aws_cloudfront_distribution.resume_dist.domain_name
}

