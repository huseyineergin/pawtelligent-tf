include "root" {
  path = find_in_parent_folders()
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  region      = local.region_vars.locals.region

  name = "nlb-sg"
}

terraform {
  source = "../../../../..//modules/terraform-aws-sgs"
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  name   = "${local.project}-${local.environment}-${local.region}-${local.name}"
  vpc_id = dependency.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 1883
      to_port     = 1883
      protocol    = "tcp"
      description = "Allow MQTT from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9001
      to_port     = 9001
      protocol    = "tcp"
      description = "Allow MQTT from anywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}