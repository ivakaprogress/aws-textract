# Creating First Lambda - response
resource "aws_lambda_function" "lambda_s3_handler" {
  function_name    = "senger-response"
  filename         = "${path.module}/senger_response.zip"
  role             = aws_iam_role.senger-iam-role.arn
  handler          = "senger_response.lambda_handler"
  runtime          = "python3.8"
  memory_size = 1024
  timeout = 900
  ephemeral_storage {
    size = 1024
  }
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policies_to_iam_role]
  source_code_hash = data.archive_file.lambda_1_zip_file.output_base64sha256
  # this line allows me to make changes on the Lambda function code and deploy on AWS
  environment { # adding the necessary variables for the function
    variables = {
      OUTPUT_BUCKET_NAME = aws_s3_bucket.my_bucket.bucket
      OUTPUT_S3_PREFIX   = "textract-output"
      SNS_TOPIC_ARN      = aws_sns_topic.senger-sns.arn
      SNS_ROLE_ARN       = aws_iam_role.SNS_role.arn
    }
  }

}

data "archive_file" "lambda_1_zip_file" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_response/"
  output_path = "${path.module}/senger_response.zip"
}


resource "aws_lambda_permission" "allow_bucket_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_s3_handler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.my_bucket.arn
}