data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "my_first_task_poc_iam" {
  name               = "my_first_task_poc_iam_v2"  # Changed name to avoid conflict
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "first_fun.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "POC_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "my_first_task_poc"
  role          = aws_iam_role.my_first_task_poc_iam.arn
  handler       = "first_fun.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
