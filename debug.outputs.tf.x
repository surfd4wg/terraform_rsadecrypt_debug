output "IPAddress-InstanceName" {
  value = [aws_eip.webserver.*.public_ip, "-", aws_instance.winrm.*.tags.Name]
}

output "Admin_Username" {
  value = "Administrator"
}

output "Admin_Password" {
  value = aws_instance.winrm.*.password_data
}

output "Admin_Password_rsadecrypted" {
  value = rsadecrypt(aws_instance.winrm.*.password_data, file(var.private_key_path))
}
