output "eip" {
  value = aws_eip.ne_staticIP[*].public_ip
}

output "ami" {
  value = data.aws_ami.linux.id
}