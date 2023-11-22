output "eip" {
  value = aws_eip.ne_staticIP[*].public_ip
}

output "ami" {
  value = data.aws_ami.linux.id
}

output "region" {
  value = data.aws_region.current.id
}
