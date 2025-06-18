output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "ec2_ssh_user" {
  value = "ubuntu"
}
