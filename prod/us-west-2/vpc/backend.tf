terraform {

  required_version = ">= 1.4.4"

  backend "s3" {
    bucket         = "221551155194-tf-statestore-us-west-2"
    key            = "prod/us-west-2/vpc/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    kms_key_id     = "alias/tf-bucket-key-us-west-2"
    dynamodb_table = "tf-lock-us-west-2"
  }
}