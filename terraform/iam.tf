locals {
  instance_roles = toset(["web", "db"])
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  for_each           = local.instance_roles
  name               = "${var.project_name}-${each.key}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = { Name = "${var.project_name}-${each.key}-ec2-role" }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  for_each   = local.instance_roles
  role       = aws_iam_role.ec2[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  for_each = local.instance_roles
  name     = "${var.project_name}-${each.key}-instance-profile"
  role     = aws_iam_role.ec2[each.key].name
}
