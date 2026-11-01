output "web_public_ip" {
  description = "Public IP of the web server"
  value       = aws_eip.web.public_ip
}

output "web_public_dns" {
  description = "Public DNS name of the web server."
  value       = aws_instance.web.public_dns
}

output "web_private_ip" {
  description = "Private IP of the web server (used by UFW on the DB host)."
  value       = aws_instance.web.private_ip
}

output "db_private_ip" {
  description = "Private IP of the MongoDB server"
  value       = aws_instance.db.private_ip
}

output "application_url" {
  description = "URL of the deployed TravelMemory application."
  value       = "http://${aws_eip.web.public_ip}"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "nat_gateway_public_ip" {
  description = "NAT gateway public IP"
  value       = aws_eip.nat.public_ip
}

output "operator_ip_cidr" {
  description = "CIDR allowed to SSH into the web server."
  value       = local.my_ip_cidr
}

output "ami_id" {
  description = "Ubuntu 22.04 AMI id that was used."
  value       = local.ami_id
}

output "ssh_web_command" {
  description = "SSH into the web server."
  value       = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${aws_eip.web.public_ip}"
}

output "ssh_db_command" {
  description = "SSH into the private DB server via the web server (ProxyJump)."
  value       = "ssh -i ${var.ssh_private_key_path} -o ProxyCommand=\"ssh -W %h:%p -i ${var.ssh_private_key_path} ${var.ssh_user}@${aws_eip.web.public_ip}\" ${var.ssh_user}@${aws_instance.db.private_ip}"
}

output "ansible_inventory_file" {
  description = "Generated Ansible inventory path."
  value       = abspath(local_file.ansible_inventory.filename)
}
