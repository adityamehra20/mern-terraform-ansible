#!/usr/bin/env bash
set -euo pipefail

echo "==> apt packages"
sudo apt-get update -y
sudo apt-get install -y curl unzip gnupg software-properties-common jq git python3 python3-pip pipx

echo "==> AWS CLI v2"
if ! command -v aws >/dev/null; then
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -qo /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install --update
fi
aws --version

echo "==> Terraform"
if ! command -v terraform >/dev/null; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -y && sudo apt-get install -y terraform
fi
terraform -version

echo "==> Ansible"
if ! command -v ansible >/dev/null; then
  pipx ensurepath
  pipx install --include-deps ansible
  export PATH="$HOME/.local/bin:$PATH"
fi
ansible --version | head -1

echo "==> Ansible collections"
cd "$(dirname "$0")/../ansible"
ansible-galaxy collection install -r requirements.yml
