locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.environment_vars.locals.environment
  account_id  = local.environment_vars.locals.account_id
  project     = local.environment_vars.locals.project
  region      = local.region_vars.locals.region
}

generate "provider" {
  if_exists = "overwrite_terragrunt"
  path      = "provider.tf"
  contents  = <<EOF
provider "aws" {
  allowed_account_ids = ["${local.account_id}"]
  profile = "${local.project}"
  region = "${local.region}"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    dynamodb_table = "${local.project}-${local.environment}-${local.region}-tfstate-lock"
    bucket         = "${local.project}-${local.environment}-${local.region}-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    profile        = local.project
    region         = local.region
    encrypt        = true
  }
  generate = {
    if_exists = "overwrite_terragrunt"
    path      = "backend.tf"
  }
}