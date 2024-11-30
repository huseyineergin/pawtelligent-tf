include "root" {
  path = find_in_parent_folders()
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  region      = local.region_vars.locals.region

  name = "ec2-sg"
}

terraform {
  source = "../../../../..//modules/terraform-aws-sgs"
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "alb_sg" {
  config_path = "../alb"
}

dependencies {
  paths = ["../../vpc", "../alb"]
}

inputs = {
  name   = "${local.project}-${local.environment}-${local.region}-${local.name}"
  vpc_id = dependency.vpc.outputs.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 1883
      to_port                  = 1883
      protocol                 = "tcp"
      description              = "Allow MQTT from ALB"
      source_security_group_id = dependency.alb_sg.outputs.security_group_id
    },
    {
      from_port                = 9001
      to_port                  = 9001
      protocol                 = "tcp"
      description              = "Allow MQTT from ALB"
      source_security_group_id = dependency.alb_sg.outputs.security_group_id
    }
  ]
}