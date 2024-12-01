include "root" {
  path = find_in_parent_folders()
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  region      = local.region_vars.locals.region

  name = "instance"
}

terraform {
  source = "../../../..//modules/terraform-aws-ec2"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "ec2_sg" {
  config_path = "../sgs/ec2"
}

dependencies {
  paths = ["../vpc", "../sgs/ec2"]
}

inputs = {
  name                        = "${local.project}-${local.environment}-${local.region}-${local.name}"
  vpc_security_group_ids      = [dependency.ec2_sg.outputs.security_group_id]
  subnet_id                   = dependency.vpc.outputs.public_subnets[0]
  ami                         = "ami-0866a3c8686eaeeba"
  key_name                    = "pawtelligent-key"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
}