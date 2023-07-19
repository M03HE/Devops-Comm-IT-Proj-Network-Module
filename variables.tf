variable "name" {
  description = "The VPC name"
  type        = string
}

variable "AWS_REGION" {
  description = "Aws region server"
  default     = "eu-west-1"
}

variable "AMI" {
  description = "The AMI that created in the ec2"
  type        = map(string)
  default = {
    eu-west-1 = "ami-01dd271720c1ba44f"
  }
}

variable "ec2_instance_type" {
  description = "The type of the instance"
  type        = string
  default     = "t2.micro"
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "vpc_cidr_block" {
  description = "CIDR block of the vpc"
  type        = string
}

variable "public_subnets_cidr_block" {
  description = "CIDR block for Public Subnet"
  type        = string
}

variable "security_access" {
  description = "CIDR block of the security groups"
  type        = list(any)
}

variable "key_pair_name" {
  description = "The name of the ec2 key pair"
  type        = string
  default     = "devops"
}
