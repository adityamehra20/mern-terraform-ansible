data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "ubuntu_2204_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

data "http" "my_ip" {
  count = var.my_ip_cidr == null ? 1 : 0
  url   = "https://checkip.amazonaws.com"
}

locals {
  az         = data.aws_availability_zones.available.names[0]
  my_ip_cidr = var.my_ip_cidr != null ? var.my_ip_cidr : "${chomp(data.http.my_ip[0].response_body)}/32"
  ami_id     = nonsensitive(data.aws_ssm_parameter.ubuntu_2204_ami.value)
}
