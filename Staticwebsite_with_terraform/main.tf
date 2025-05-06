
########### Creating S3 Bucket ############

## Create Bucket
resource "aws_s3_bucket" "static-website-hoster" {
  bucket = "my-static-website-hoster134"
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
    object_ownership = "BucketOwnerEnforced"
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

## bucket policy to allow public access to the bucket
resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.static-website-hoster.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static-website-hoster.arn}/*"
      }
    ]
  })
}


######################################################################################################
# End of policy block
######################################################################################################

############## Uploading upjects ###############

# uploading index.html file
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static-website-hoster.id
  key    = "index.html"
  source = "./index.html" ## If found in same directory, just give name .e.g index.html
  content_type = "text/html"
}
#uploading error.html file
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.static-website-hoster.id
  key    = "error.html"
  source = "./error.html" 
  content_type = "text/html"
}

##upload picture to be used by the index.html file

##image one
resource "aws_s3_object" "profile_picture1" {
  bucket = aws_s3_bucket.static-website-hoster.id
  key    = "cameroonian-dish-1.jpg"
  source = "./cameroonian-dish-1.jpg"
  content_type = "image/jpg"
}

##image two
resource "aws_s3_object" "profile_picture2" {
  bucket = aws_s3_bucket.static-website-hoster.id
  key    = "cameroonian-dish-2.jpg"
  source = "./cameroonian-dish-2.jpg" 
  content_type = "image/jpg"
}

## image three
resource "aws_s3_object" "profile_picture3" {
  bucket = aws_s3_bucket.static-website-hoster.id
  key    = "Kenyan-dish-1.jpg"
  source = "./Kenyan-dish-1.jpg" 
  content_type = "image/jpg"
}

## image four
resource "aws_s3_object" "profile_picture4" {
  bucket = aws_s3_bucket.static-website-hoster.id
  key    = "Kenyan-dish-2.jpg"
  source = "./Kenyan-dish-2.jpg" 
  content_type = "image/jpg"
}

## Renders S3 bucket a host for static website 
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static-website-hoster.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

depends_on = [ aws_s3_bucket_policy.public_access ]
}

## Note that you can also upload your CSS. files 
## As well as all other photos that will be used by the index.html file
