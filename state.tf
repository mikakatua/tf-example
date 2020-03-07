terraform {
  required_version = ">= 0.12, < 0.13"

  required_providers {
    aws = "~> 2.51"
  }
/*
  # WARNING: Variables aren't allowed in a backend configuration
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "mycompany-tfstate"
    key            = "stage/example/terraform.tfstate"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "tfstate-locks"
    encrypt        = true
  }
*/
}

# Amazon S3 bucket to store state files
resource "aws_s3_bucket" "tf_state" {
  # Replace this with your bucket name!
  bucket = "mycompany-tfstate"

  # Prevent accidental deletion of this S3 bucket
#  lifecycle {
#    prevent_destroy = true
#  }

  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# DynamoDB table used for locking
resource "aws_dynamodb_table" "tf_locks" {
  # Replace this with your DynamoDB table name!
  name         = "tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
