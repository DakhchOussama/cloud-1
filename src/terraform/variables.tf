variable "aws_region" {
  description = "AWS region to deploy resources"
  type = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "AMI id of EC2 instance"
  type = string
}

variable "instance_type" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "my_ip" {
  description = "IP public IP for SSH / phpMyAdmin"
  type        = string
}
