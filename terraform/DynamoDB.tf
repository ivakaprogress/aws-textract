resource "aws_dynamodb_table" "senger-textract" {
  name = "senger-textract"
  billing_mode = "PROVISIONED"
  read_capacity = 20
  write_capacity = 20
  hash_key = "senger"
  attribute {
    name = "senger"
    type = "S"
  }
}
