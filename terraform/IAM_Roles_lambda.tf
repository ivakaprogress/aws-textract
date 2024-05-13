# Create IAM_ROLE for textract-response
resource "aws_iam_role" "textract-iam-role" {
  name = "textract-IAM-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create policy for textract-response IAM
resource "aws_iam_policy" "textract_s3" {
  name        = "textract-s3-textract"
  description = "AWS IAM Policies for managing Lambda role"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogStreams"
          ],
            "Resource": [
              "arn:aws:logs:*:*:*"
          ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "textract:*"
            ],
            "Resource": "*"
        }
    ]
}
  EOF
}

# Attaches IAM policies to IAM role
resource "aws_iam_role_policy_attachment" "attach_iam_policies_to_iam_role" {
  policy_arn = aws_iam_policy.textract_s3.arn
  role       = aws_iam_role.textract-iam-role.name
}

# Create policy for textract-response IAM
resource "aws_iam_policy" "lambda_output_dynamodb" {
  name        = "lambda_output_dynamodb"
  description = "AWS IAM Policies for managing Lambda role"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "dynamodb:PutItem"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/textract-textract"
        }
]
}
  EOF
}

# Attaches IAM policies to IAM role
resource "aws_iam_role_policy_attachment" "attach_iam_policies_to_iam_role_output" {
  policy_arn = aws_iam_policy.lambda_output_dynamodb.arn
  role       = aws_iam_role.textract-iam-role.name
}