//cloud watch loggroup
resource "aws_cloudwatch_log_group" "cost_opti" {
  name = "/aws/lambda/${var.function_name}_function_${var.suffix}"

  tags = {
    NAME = "cost_opti"
  }
}


//lambda role
resource "aws_iam_role" "cost_opti" {
  name               = "${var.function_name}_role"
  path               = "/"
  description        = "Allows Lambda Function to call AWS services on your behalf."
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
       "Sid": ""
    }
  ]
}
EOF
}

// added powers 1
resource "aws_iam_policy" "cost_opti_instances" {
  name        = "${var.function_name}_S3_policy"
  path        = "/"
  description = "cost opti instances policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Describe*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

//standard aws added powers  Lambda execution
resource "aws_iam_role_policy_attachment" "cost_opti" {
  role       = aws_iam_role.cost_opti.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

//aws standard added powers  s3 full access
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.cost_opti.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

// adding my added powers 1
resource "aws_iam_role_policy_attachment" "cost_opti_instances" {
  role       = aws_iam_role.cost_opti.name
  policy_arn = aws_iam_policy.cost_opti_instances.arn
}


// aws standard added powers : Full SES Access added 
resource "aws_iam_role_policy_attachment" "ses_full_access" {
  role       = aws_iam_role.cost_opti.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

//lambda layer
resource "aws_lambda_layer_version" "cost_opti" {
  filename            = data.archive_file.lambda_zip.output_path
  layer_name          = "${var.function_name}_layer_version"
  compatible_runtimes = [var.runtime]
}


//deploy lambda function
resource "aws_lambda_function" "cost_opti" {
  function_name = "${var.function_name}_function_${var.suffix}"

  role             = aws_iam_role.cost_opti.arn
  handler          = var.handler
  runtime          = var.runtime
  filename         = data.archive_file.lambda_zip.output_path
  #layers           = [aws_lambda_layer_version.cost_opti.arn]
  #source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  source_code_hash = "${filebase64sha256(data.archive_file.lambda_zip.output_path)}"
  #source_code_hash = "${filebase64sha256(${path.module}/lambda/lambda_zip)}"

  environment {
    variables = {
      kmsEncryptedHookUrl	= var.kmsEncryptedHookUrl
      slackChannel = var.slackChannel
    }
  }
}

resource "aws_lambda_alias" "cost_opti" {
  name             = "${var.function_name}_alias"
  description      = "Cloudwatch Alias for EC2 cost opti"
  function_name    = aws_lambda_function.cost_opti.arn
  function_version = aws_lambda_function.cost_opti.version
}

//new  permissions to allow trigger
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_opti.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.bucket.arn
 # qualifier     = aws_lambda_alias.cost_opti.name
}

//new
resource "aws_s3_bucket" "bucket" {
  #bucket = "your_bucket_name"
  bucket = var.s3_bucket_store
}


// new replace below
// https://www.terraform.io/docs/providers/aws/r/s3_bucket_notification.html
// https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"
  #bucket = "${var.s3_bucket_store.bucket.id}"
  lambda_function {
    #lambda_function_arn = "${aws_lambda_function.func.arn}"

    lambda_function_arn = aws_lambda_function.cost_opti.arn
    events              = ["s3:ObjectCreated:*"]
    #filter_prefix       = "AWSLogs/"
    #filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_bucket]

}

//lambda trigger  old
//resource "aws_s3_bucket_notification" "cost_opti_s3_trigger" {
//    bucket = data.aws_s3_bucket.bucket.id
//
//    lambda_function {
//        lambda_function_arn = aws_lambda_alias.cost_opti.arn
//        events              = ["s3:ObjectCreated:*"]
//        filter_suffix       = ".csv"
//    }
//}
