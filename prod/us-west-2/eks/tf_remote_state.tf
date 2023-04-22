data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "221551155194-tf-statestore-us-west-2"
    key    = "prod/us-west-2/vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "project" {
  backend = "s3"
  config = {
    bucket = "221551155194-tf-statestore-us-west-2"
    key    = "prod/us-west-2/project/terraform.tfstate"
    region = "us-west-2"
  }
}
