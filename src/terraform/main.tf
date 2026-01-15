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
