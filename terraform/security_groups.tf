resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Web/bastion server: SSH from operator IP, HTTP/HTTPS from allowed CIDRs"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.project_name}-web-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH from operator IP only"
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  for_each          = toset(var.allowed_http_cidrs)
  security_group_id = aws_security_group.web.id
  description       = "HTTP (nginx: React build and /api proxy)"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  for_each          = toset(var.allowed_http_cidrs)
  security_group_id = aws_security_group.web.id
  description       = "HTTPS (ready for a TLS certificate; nginx listens on 80 by default)"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound (apt, npm, GitHub, MongoDB in private subnet)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "MongoDB server: 27017 and SSH only from the web security group"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.project_name}-db-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "db_mongo_from_web" {
  security_group_id            = aws_security_group.db.id
  description                  = "MongoDB from the web server only"
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 27017
  to_port                      = 27017
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "db_ssh_from_web" {
  security_group_id            = aws_security_group.db.id
  description                  = "SSH via the web server acting as jump host"
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.db.id
  description       = "All outbound via NAT gateway (apt, MongoDB repo)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
