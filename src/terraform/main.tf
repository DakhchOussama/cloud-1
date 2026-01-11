module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.cidr_block
  aws_region = var.aws_region
}

module "security_group" {
  source = "./modules/security-group"
  vpc_id = module.vpc.vpc_id
  my_ip  = var.my_ip
}

module "ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id
  sg_id         = module.security_group.sg_id
}


# terraform {

#   required_version = ">= 1.14.3"

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "6.27.0"
#     }
#   }
# }

# provider "aws" {
#   region = var.aws_region
# #   access_key = "never_gonna_give_you_up"
# #   secret_key = "never_gonna_let_you_down"
# }

# resource "aws_instance" "this" {
#   ami = var.ami_id
#   instance_type = var.instance_type
# #   key_name = var.key_name

#   tags = {
# 	ami_choice_reason = "Official Canonical Ubuntu 22.04 LTS, Free, t3.micro for free tier, EBS gp2 and gp3 eligible"
# 	# name = var
#   }
# }

# resource "aws_vpc" "hello-world-aws_vpc" {
#   cidr_block = var.cidr_block
# }
