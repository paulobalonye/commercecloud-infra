output "tf_state_s3_bucket_id" {
  description = "Terraform S3 state bucket id"
  value       = aws_s3_bucket.terraform_state.id
}