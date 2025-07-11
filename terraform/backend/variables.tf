variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket to store Terraform state"
}
 
variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table for Terraform state locking"
}