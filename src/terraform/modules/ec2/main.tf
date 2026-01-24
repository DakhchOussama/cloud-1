resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_id]
  associate_public_ip_address = false
  key_name                    = var.key_name

  tags = {
    Name = "wordpress-host"
  }
}

resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "wordpress-eip"
  }
}

resource "aws_eip_association" "this" {
  allocation_id = aws_eip.this.id
  instance_id   = aws_instance.this.id
}
