# Create S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "textract-async-${random_string.random.result}"
  force_destroy = true
}
# adding trigger configuration
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_handler.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix = "async-kv-table/"
    filter_suffix = ".pdf"
  }

  depends_on = [aws_lambda_permission.allow_bucket_invoke_lambda]
}

resource "aws_s3_object" "upload_file" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "async-kv-table/"
  content_type = "application/x-directory"
}

resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  numeric = true
  upper   = false
}