variable "aws_region" {
  description = "This is a Hello World EC2 instance"
  type        = string
  default     = "eu-north-1"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0068163775a114e89" # Official Canonical Ubuntu 22.04 LTS, Free
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t3.micro" # Free tier eligible
}

# variable "key_name" {
#   description = "The name of the key pair to use for the EC2 instance"
#   type        = string
#   default     = "my-key-pair" # Replace with your actual key pair nam	e
# }

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
