variable "aws_region" {
  type = string
}

variable "ami_id" {
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
