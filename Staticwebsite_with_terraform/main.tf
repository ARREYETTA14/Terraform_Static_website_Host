## Create Bucket
resource "aws_s3_bucket" "static-website-hoster" {
  bucket = "my-static-website-hoster"
  tags = {
    Name        = var.bucket_name
  }
}

######################################################################################################
# Policy Block 
######################################################################################################

## Ownership Control to show that everything in this bucket is owned by you. So no one changes anything 
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.static-website-hoster.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

## Make bucket public
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.static-website-hoster.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

## Bucket ACLs
resource "aws_s3_bucket_acl" "Acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.static-website-hoster.id
  acl    = "public-read"
}
######################################################################################################
# End of policy block
######################################################################################################

## Upload objects in bucket
# uploading index.html file
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static-website-hoster.id
  key    = "index.html"
  source = "./index.html" ## If found in same directory, just give name .e.g index.html
  acl = "public-read"
  # content_type = "text/html"
}
#uploading error.html file
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.static-website-hoster.id
  key    = "error.html"
  source = "./error.html" ## If found in same directory, just give name .e.g error.html
  acl = "public-read"
  # content_type = "text/html"
}

##upload picture to be be used by the index.html file
resource "aws_s3_object" "profile_picture" {
  bucket = aws_s3_bucket.static-website-hoster.id
  key    = "profile.jpg"
  source = "./profile.jpg" ## If found in same directory, just give name .e.g profile.jpg
  acl = "public-read"
}

## Renders S3 bucket a host for static website 
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static-website-hoster.id

  index_document {
    suffix = var.index_document_suffix
  }

  error_document {
    key = var.error_document
  }

depends_on = [ aws_s3_bucket_acl.Acl ]
}

## Note that, you can as well upload your css. files 
## As well as all other photos that will be usedby the index.html file
