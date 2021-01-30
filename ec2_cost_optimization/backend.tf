# terraform {
#   backend "s3" {
#     region = "eu-west-1"
#     dynamodb_table = "terraform-state-lock"

#     bucket = "10x-infrastructureci-terraform-state"
#     // Uncomment once the environment is created and the key decided
#     key = "infrastructure/cost-opti/terraform.tfstate"
#   }
# }