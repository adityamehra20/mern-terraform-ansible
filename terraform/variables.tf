variable "project_name" {
  description = "Prefix for resource names"
  type        = string
  default     = "travelmemory"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "my_ip_cidr" {
  description = "IP allowed to SSH to the web server, null = auto-detect"
  type        = string
  default     = null

  validation {
    condition     = var.my_ip_cidr == null || can(cidrnetmask(var.my_ip_cidr))
    error_message = "my_ip_cidr must be a valid IPv4 CIDR."
  }
}

variable "allowed_http_cidrs" {
  description = "CIDRs allowed on 80/443"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "key_pair_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "travelmemory-key"
}

variable "ssh_public_key_path" {
  description = "SSH public key path"
  type        = string
  default     = "~/.ssh/travelmemory-key.pub"
}

variable "ssh_private_key_path" {
  description = "SSH private key path (used in the ansible inventory)"
  type        = string
  default     = "~/.ssh/travelmemory-key"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "web_instance_type" {
  description = "Web server instance type"
  type        = string
  default     = "t3.small"
}

variable "db_instance_type" {
  description = "DB server instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size_gb" {
  description = "Root volume size in GB"
  type        = number
  default     = 16
}

variable "ansible_inventory_path" {
  description = "Output path for the ansible inventory"
  type        = string
  default     = "../ansible/inventory/hosts.yml"
}
