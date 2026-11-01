#!/usr/bin/env bash
# usage: 02_terraform_apply.sh [-auto]
set -euo pipefail
cd "$(dirname "$0")/../terraform"

AUTO=""
[[ "${1:-}" == "-auto" ]] && AUTO="-auto-approve"

if [[ ! -f terraform.tfvars ]]; then
  cp terraform.tfvars.example terraform.tfvars
  echo "Created terraform.tfvars, edit it and run again"
  exit 1
fi

aws sts get-caller-identity --output table

terraform init -input=false
terraform fmt -check -recursive
terraform validate
terraform plan -input=false
terraform apply -input=false $AUTO

terraform output
