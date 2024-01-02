provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

resource "aws_s3_bucket" "bucketapp" {
  bucket = "app-bucket"
}


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

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda/index.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "app" {
  filename      = "lambda_function_payload.zip"
  function_name = "myapp"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda/index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime = "nodejs18.x"

  environment {
    variables = {
    }
  }
}