include "root" {
  path = find_in_parent_folders()
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  region      = local.region_vars.locals.region

  name = "volume"
}

terraform {
  source = "../../../..//modules/terraform-aws-ebs"
}

dependency "ec2" {
  config_path = "../ec2"
}

dependencies {
  paths = ["../ec2"]
}

inputs = {
  instance_id       = dependency.ec2.outputs.id
  availability_zone = "us-east-1a"
  device_name       = "/dev/sdf"
  type              = "gp3"
  encrypted         = true
  size              = 2

  tags = {
    Name = "${local.project}-${local.environment}-${local.region}-${local.name}"
  }
}