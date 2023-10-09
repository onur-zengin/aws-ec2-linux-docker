output "amiId" {
  value = data.aws_ami.linux.id
}
/*
output "amiObject" {
  value = data.aws_ami.linux // full object definition 
}

output "availabilityZones" {
  value = data.aws_availability_zones.available
}

output "testAz_ec2" {
  value = aws_instance.ec2.availability_zone
}

output "testAz_ebs" {
  value = aws_ebs_volume.ebs.availability_zone
}
*/