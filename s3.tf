# S3 build guide >>> https://github.com/fang-lin/function-plotter/blob/master/terraform/main.tf

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.bucket_name
}

# # Archive static files
# data "archive_file" "source-code-zip" {
#   type = "zip"
#   source_file = "./static"
#   output_path = ".static.zip"
# }

# # Upload index.html object
# resource "aws_s3_object" "index_html" {
#   bucket = aws_s3_bucket.frontend_bucket.id
#   key    = "index.html"
#   source = "./static/index.html"
#   content_type = "text/html"

#   # The filemd5() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
#   # etag = "${md5(file("path/to/file"))}"
#   # etag = filemd5("../index.html")
# }

# # Upload style.css object
# resource "aws_s3_object" "style_css" {
#   bucket = aws_s3_bucket.frontend_bucket.id
#   key    = "style.css"
#   source = "./static/style.css"

# #   # The filemd5() function is available in Terraform 0.11.12 and later
# #   # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
# #   # etag = "${md5(file("path/to/file"))}"
# #   etag = filemd5("../public/")
# }

resource "aws_s3_bucket_website_configuration" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

#   error_document {
#     key = "404.html"
#   }
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.frontend_bucket.id
  acl    = "private"
  depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership ]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [ aws_s3_bucket_public_access_block.bucket_access_block ]
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.frontend_bucket.arn}/*"
        ]
      }
    ]
  })
}