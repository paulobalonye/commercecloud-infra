module "project" {
  source = "git::https://github.com/computeoncloud/terraform-aws-modules.git//project?ref=main"
  # source = "/Users/hassan/Desktop/COC/repos/terraform-aws-modules/project"

  project = "infra"
  env     = "prod"
  client  = "commercecloud"

  extra_tags = {
    "coc:owner"   = "ComputeOnCloud",
    "coc:project" = "migration",
    "coc:env"     = "prod",
  }
}