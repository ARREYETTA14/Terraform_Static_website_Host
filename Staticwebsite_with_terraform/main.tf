# 1. Create the S3 Bucket resource
resource "aws_s3_bucket" "static-website-hoster" {
  bucket = var.bucket_name

  tags = {
    Name        = "African Restaurant Web Hoster"
    Environment = "Production"
  }
}

# 2. Modern AWS Security Standard: Enforce Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.static-website-hoster.id

  rule {
    object_ownership = "BucketOwnerEnforced" # Keeps legacy ACLs safely disabled
  }
}

# 3. Unblock Public Access (Mandatory step for public static hosting)
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.static-website-hoster.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Turn the S3 Bucket into a Static Web Server
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static-website-hoster.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# 5. Attach a Public Read Policy (Explicitly relies on the Public Access Block finish first!)
resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.static-website-hoster.id

  # CRITICAL: Forces Terraform to wait until Public Access is completely unlocked before applying policy
  depends_on = [aws_s3_bucket_public_access_block.example]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static-website-hoster.arn}/*"
      }
    ]
  })
}

# 6. Upload Core Document Files (with accurate Content-Type mappings)
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static-website-hoster.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.static-website-hoster.id
  key          = "error.html"
  source       = "${path.module}/error.html"
  content_type = "text/html"
}

resource "aws_s3_object" "styles" {
  bucket       = aws_s3_bucket.static-website-hoster.id
  key          = "styles.css"
  source       = "${path.module}/styles.css"
  content_type = "text/css"
}

# 7. Dynamically Upload All Images (Scans root for any jpg, jpeg, or png files)
resource "aws_s3_object" "restaurant_images" {
  for_each = fileset(path.module, "*.{jpg,jpeg,png}")

  bucket       = aws_s3_bucket.static-website-hoster.id
  key          = each.value
  source       = "${path.module}/${each.value}"
  
  # Map image extensions dynamically so the browser renders them instead of downloading them
  content_type = lookup({
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "png"  = "image/png"
  }, element(split(".", each.value), length(split(".", each.value)) - 1), "binary/octet-stream")
}
