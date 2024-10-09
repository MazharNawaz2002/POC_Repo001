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

resource "aws_iam_role" "iam_for_my_first_task_poc" {
  name               = "iam_for_my_first_task_poc"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "first_fun.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "POC_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "my_first_task_poc"
  role          = aws_iam_role.iam_for_my_first_task_poc.arn
  handler       = "first_fun.lambda_handler"
  layers = ["arn:aws:lambda:us-west-2:336392948345:layer:AWSSDKPandas-Python312:9"]

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  environment {
    variables = {
      foo = "bar"
    }
  }
}


