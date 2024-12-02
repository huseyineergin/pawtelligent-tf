include "root" {
  path = find_in_parent_folders()
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  region      = local.region_vars.locals.region

  name = "nlb"
}

terraform {
  source = "../../../..//modules/terraform-aws-elb"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "ec2" {
  config_path = "../ec2"
}

dependency "nlb_sg" {
  config_path = "../sgs/nlb"
}

dependencies {
  paths = ["../vpc", "../ec2", "../sgs/nlb"]
}

inputs = {
  name                       = "${local.project}-${local.environment}-${local.region}-${local.name}"
  security_groups            = [dependency.nlb_sg.outputs.security_group_id]
  subnets                    = [dependency.vpc.outputs.public_subnets[0]]
  vpc_id                     = dependency.vpc.outputs.vpc_id
  load_balancer_type         = "network"
  enable_deletion_protection = false
  create_security_group      = false

  target_groups = {
    mqtt-1 = {
      name        = "mqtt-1"
      protocol    = "TCP"
      port        = 1883
      target_type = "instance"
      target_id   = dependency.ec2.outputs.id
      health_check = {
        path    = "/health"
        matcher = "200"
        port    = 3000
      }
    }
  }

  listeners = {
    mqtt-forward-1 = {
      port     = 1883
      protocol = "TCP"
      forward = {
        target_group_key = "mqtt-1"
      }
    }
  }
}