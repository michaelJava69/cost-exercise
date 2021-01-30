variable "suffix" {}
variable "s3_bucket_store" {}
variable "function_name" {
  default = "ec2_cost_opti"
}
variable "slackChannel" {}
variable "kmsEncryptedHookUrl" {}
variable "handler" {
  default = "lambda.handler"
}
variable "runtime" {
  default = "python3.8"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda.py"
  output_path = "${path.module}/lambda/lambda.zip"
}

data "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_store
}
