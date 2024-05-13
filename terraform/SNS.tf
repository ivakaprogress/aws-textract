# Create SNS topic
resource "aws_sns_topic" "textract-sns" {
  name = "textract-notification-sns"
}

# Create SNS topic subscription for second Lambda
resource "aws_sns_topic_subscription" "subsc-for-l-2" {
  endpoint   = aws_lambda_function.lambda_sns_handler.arn # SNS topic arn
  protocol   = "lambda" # needed to conn to lambda
  topic_arn  = aws_sns_topic.textract-sns.arn# L_2 arn
  depends_on = [aws_lambda_function.lambda_sns_handler]
}

# Allow SNS topic to invoke Lambda
resource "aws_lambda_permission" "allow_invocation_from_sns" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_sns_handler.function_name}"
  principal     = "sns.amazonaws.com"
  statement_id = "AllowExecutionFromSNS"
  source_arn = aws_sns_topic.textract-sns.arn
}

