resource "aws_cloudformation_stack" "cost_opti" {
  name         = "cost-opti-${var.suffix}"
  capabilities = ["CAPABILITY_IAM"]

  parameters = {
    InboundTraffic = var.InboundTraffic
    BucketName     = var.BucketName
    KeyName        = var.KeyName

  }
  #template_url = "https://cap-dev-cost-opti.s3.eu-west-2.amazonaws.com/cf/cost-optimization.yaml"
   template_url = "https://capgemini-ec2pricing.s3.us-east-1.amazonaws.com/template/cost-optimization-ec2-right-sizing-2.template"
}
