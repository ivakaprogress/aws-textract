# Creating Second Lambda - output
resource "aws_lambda_function" "lambda_sns_handler" {
  function_name = "senger-lambda-output"
  filename      = "${path.module}/senger_output.zip"
  role          = aws_iam_role.senger-iam-role.arn
  handler       = "senger_output.lambda_handler"
  runtime       = "python3.8"
  memory_size   = 1024
  timeout       = 900
  ephemeral_storage {
    size = 1024
  }
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policies_to_iam_role]
  source_code_hash = data.archive_file.lambda_2_zip_file.output_base64sha256
  layers           = ["arn:aws:lambda:eu-central-1:336392948345:layer:AWSSDKPandas-Python38:3"] # Pandas Layer
  # this line allows me to make changes on the Lambda function code and deploy on AWS
  environment {
    variables = {
      DYNAMODB = aws_dynamodb_table.senger-textract.name
    }
  }
}

data "archive_file" "lambda_2_zip_file" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_output/"
  output_path = "${path.module}/senger_output.zip"
}



