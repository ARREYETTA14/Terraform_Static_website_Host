output "website_url" {
  value = aws_s3_bucket.static-website-hoster.website_endpoint
}
