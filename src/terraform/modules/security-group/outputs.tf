output "sg_id" {
  value = aws_security_group.this.id
}

output "key_pair_name" {
  value = aws_key_pair.ec2.key_name
}
