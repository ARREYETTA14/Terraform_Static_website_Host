
# ## s3 backend bucket
# resource "aws_s3_bucket" "tf_state_bucket" {
#   bucket = "my-terraform-backend-bucket1234"

    force_destroy = true

#   tags = {
#     Name = "Terraform State Bucket"
#   }
# }

# ## creating dynamoDB table for state locking
# resource "aws_dynamodb_table" "tf_state_lock" {
#   name         = "terraform-lock-table1234"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Name = "Terraform Lock Table"
#   }
# }
