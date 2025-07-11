# Create an S3 bucket to store Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name  # ✅ Use a variable for flexibility across environments

  tags = {
    Name        = "terraform-state"  # ✅ Helps identify the resource
    Environment = "dev"              # ❗ In production, use "prod" or environment-specific value
  }
}

# Enable versioning on the S3 bucket to keep history of state files
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id  # ✅ Link to the S3 bucket

  versioning_configuration {
    status = "Enabled"  # ✅ Essential for recovering from accidental changes
  }
}

# Enable server-side encryption on the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id  # ✅ Apply to the same bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # ❗ In production, prefer "aws:kms" for better control
    }
  }
}

# ✅ Production alternative:
# sse_algorithm     = "aws:kms"
# kms_master_key_id = aws_kms_key.terraform_state_key.arn

# Create a DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name  # ✅ Use variable for flexibility
  billing_mode = "PAY_PER_REQUEST"        # ❗ In production, consider "PROVISIONED" for cost optimization
  hash_key     = "LockID"                 # ✅ Required by Terraform for locking

  attribute {
    name = "LockID"  # ✅ Primary key
    type = "S"       # ✅ String type
  }

  tags = {
    Name        = "terraform-locks"  # ✅ Helps identify the table
    Environment = "dev"              # ❗ Use "prod" or environment-specific value in production
  }
}
