# Create IAM for textract-SNS
resource "aws_iam_role" "SNS_role" {
  name = "textract-SNS-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "textract.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
  EOF
}
# IAM Policies for attaching to IAM role about managing SNS
resource "aws_iam_policy" "sns-textract" {
  name        = "textract-sns-textract"
  description = "AWS IAM Policies for managing SNS"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "arn:aws:sns:*:*:AmazonTextract*"
        },
        {
            "Action": [
                "sns:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
  EOF
}
# attaching
resource "aws_iam_role_policy_attachment" "attach-sns-policies" {
  policy_arn = aws_iam_policy.sns-textract.arn
  role       = aws_iam_role.SNS_role.name
}