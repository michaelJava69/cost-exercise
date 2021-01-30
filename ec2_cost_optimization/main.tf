resource "random_id" "suffix" {
  byte_length = 4
}

module "cost_opti_lambda" {
  source = "./module/cost-opti-lambda"
   suffix = random_id.suffix.hex
   s3_bucket_store = "capgemini-ec2pricing-auto"
   handler = "lambda.lambda_handler"
   kmsEncryptedHookUrl = "https://hooks.slack.com/services/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"
   slackChannel = "test"
}

module "cost_opti_cf" {
  source = "./module/cost-opti-cf"
   suffix = random_id.suffix.hex
  #  BucketName = "capgemini-ec2-pricing-london"

   BucketName = "capgemini-ec2pricing-auto"
   KeyName = "Michael-N-Virginia"
}

