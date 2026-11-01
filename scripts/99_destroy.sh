#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform"

terraform destroy

REGION="$(grep -E '^\s*aws_region' terraform.tfvars 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/')"
REGION="${REGION:-ap-south-1}"
aws ec2 describe-instances --region "$REGION" \
  --filters "Name=tag:Project,Values=travelmemory" "Name=instance-state-name,Values=pending,running,stopping,stopped" \
  --query 'Reservations[].Instances[].{Id:InstanceId,State:State.Name}' --output table
aws ec2 describe-nat-gateways --region "$REGION" --filter "Name=tag:Project,Values=travelmemory" \
  --query 'NatGateways[].{Id:NatGatewayId,State:State}' --output table
aws ec2 describe-addresses --region "$REGION" --filters "Name=tag:Project,Values=travelmemory" \
  --query 'Addresses[].PublicIp' --output table

rm -f ../ansible/inventory/hosts.yml
