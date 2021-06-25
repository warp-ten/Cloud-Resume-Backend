resource "aws_iam_role" "lambda-visit-count-role" {
  name = "lambda-visit-count"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Project = "cloud-resume"
    Provisioner = "terraform"
  }
}

resource "aws_iam_policy" "lambda-visit-count-policy" {
  name = "lambda_counter_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "${aws_dynamodb_table.viewcount.arn}",
          "${aws_lambda_function.lambda-visit-count-function.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "visit-count-role-policy-attachement" {
  role       = aws_iam_role.lambda-visit-count-role.name
  policy_arn = aws_iam_policy.lambda-visit-count-policy.arn
}

resource "aws_lambda_function" "lambda-visit-count-function" {
  filename      = "../visit-count.zip"  
  function_name = "visit-count-function"
  role          = aws_iam_role.lambda-visit-count-role.arn

  #The value of the handler setting is the file name and the name of the handler module, separated by a dot. 
  #For example, main.Handler calls the Handler method defined in main.py.
  handler       = "visit-count.lambda_handler"

  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../visit-count.zip")

  runtime = "python3.8"
  
  tags = {
    Project = "cloud-resume"
    Provisioner = "terraform"
  }
}