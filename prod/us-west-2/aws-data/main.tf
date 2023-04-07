variable "aws_region" {
  type        = string
  description = "Region to deploy resources."
}

provider "aws" {
  region = var.aws_region
}

data "aws_region" "selected" {}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}


data "aws_partition" "current" {}


output "partition" {
  value = data.aws_partition.current.partition
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}


output "aws_region" {
  description = "Details about selected AWS region"
  value       = data.aws_region.selected
}

output "available_aws_availability_zones_names" {
  description = "A list of the Availability Zone names available to the account"
  value       = data.aws_availability_zones.available.names
}

output "available_aws_availability_zones_zone_ids" {
  description = "A list of the Availability Zone IDs available to the account"
  value       = data.aws_availability_zones.available.zone_ids
}
