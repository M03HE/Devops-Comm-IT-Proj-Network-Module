locals {
  ###VPC
  name                      = var.name
  cidr_block                = var.vpc_cidr_block
  public_subnets_cidr_block = var.public_subnets_cidr_block
  security_access           = var.security_access
  ###EC2
  private_key_path    = "./devops.pem"
  key_name            = "devops"
}
