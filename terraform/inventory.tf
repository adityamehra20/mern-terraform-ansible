resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/${var.ansible_inventory_path}"
  file_permission = "0644"

  content = templatefile("${path.module}/templates/inventory.yml.tftpl", {
    web_public_ip       = aws_eip.web.public_ip
    web_private_ip      = aws_instance.web.private_ip
    db_private_ip       = aws_instance.db.private_ip
    ssh_user            = var.ssh_user
    ssh_private_key     = var.ssh_private_key_path
    vpc_cidr            = var.vpc_cidr
    public_subnet_cidr  = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
    aws_region          = var.aws_region
  })
}
