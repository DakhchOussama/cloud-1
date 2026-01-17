variable "vpc_id" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/ec2_instance.pub"
}