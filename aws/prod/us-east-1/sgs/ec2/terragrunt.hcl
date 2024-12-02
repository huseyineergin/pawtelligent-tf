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

dependency "nlb_sg" {
  config_path = "../nlb"
}

dependencies {
  paths = ["../../vpc", "../nlb"]
}

inputs = {
  name        = "${local.project}-${local.environment}-${local.region}-${local.name}"
  vpc_id      = dependency.vpc.outputs.vpc_id
  description = "Security Group for EC2"

  ingress_with_source_security_group_id = [
    {
      from_port                = 1883
      to_port                  = 1883
      protocol                 = "tcp"
      description              = "Allow MQTT from NLB"
      source_security_group_id = dependency.nlb_sg.outputs.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}