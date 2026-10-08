variable "aws_region" {
  type        = string
  description = "The AWS Region to deploy your website bucket into"
  default     = "sa-east-1"
}

variable "bucket_name" {
  type        = string
  description = "The globally unique name for your static website S3 bucket"
}
