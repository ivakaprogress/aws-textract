resource "aws_dynamodb_table" "textract-textract" {
  name = "textract-textract"
  billing_mode = "PROVISIONED"
  read_capacity = 20
  write_capacity = 20
  hash_key = "textract"
  attribute {
    name = "textract"
    type = "S"
  }
}
