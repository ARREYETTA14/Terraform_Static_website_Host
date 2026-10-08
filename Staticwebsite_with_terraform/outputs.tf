output "website_url" {
  description = "The live public HTTP URL of your deployed static website"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}
