output "eip" {
  value = aws_eip.ne_static_ip[*].public_ip
}

output "ami" {
  value = data.aws_ami.linux.id
}

output "region" {
  value = data.aws_region.current.id
}
