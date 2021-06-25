resource "aws_dynamodb_table" "viewcount" {
  name           = "resume-view-count"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 4
  hash_key       = "count"

  attribute {
    name = "count"
    type = "S"
  }
  tags = {
    Name    = "Cloud-Resume"
    Project = "resume"
    Provisioner = "terraform"
  }
}

resource "aws_dynamodb_table_item" "init-item" {
  table_name = aws_dynamodb_table.viewcount.name
  hash_key   = aws_dynamodb_table.viewcount.hash_key
  depends_on = [aws_dynamodb_table.viewcount]
  item = <<ITEM
{
  "count": {"S": "count"},
  "total": {"N": "0"}
}
ITEM
}