# # # Below is Backend block
# terraform {
#   backend "s3" {
#     bucket = "my-terraform-backend-bucket1234"
#     key = "terratest/terratest.tfstate"
#     region = "sa-east-1"
#     dynamodb_table = "terraform-lock-table1234"
#   }
# }