# TravelMemory - Terraform + Ansible

Deploys the [TravelMemory](https://github.com/adityamehra20/TravelMemory) MERN app on AWS (ap-south-1).

- Terraform creates the VPC, public/private subnets, IGW, NAT gateway, route tables, security groups, IAM roles and two EC2 instances. It also writes the Ansible inventory.
- Ansible installs MongoDB (with auth) on the private instance, and Node.js, the Express backend (systemd), the React build and nginx on the public instance. Both hosts get basic SSH/UFW/fail2ban hardening.

## Architecture

```
Internet -> IGW -> web EC2 (public subnet, nginx :80)
                     |- /      -> React build
                     |- /api/  -> Express :3001
                                    |
                                    v
                   db EC2 (private subnet, MongoDB :27017)
                     outbound via NAT gateway
```

- SSH to web: only from my IP.
- db: no public IP. 22 and 27017 only from the web security group. Ansible reaches it through the web server as a jump host.

## Layout

```
terraform/   infrastructure
ansible/     playbooks and roles (common, mongodb, web)
scripts/     helper scripts (run from WSL/Linux)
screenshots/
```

## Requirements

- AWS CLI configured (`aws sts get-caller-identity` works)
- Terraform >= 1.5
- Ansible >= 2.15 (WSL on Windows)
- `ansible-galaxy collection install -r ansible/requirements.yml`

## Steps

```bash
# tools (WSL)
bash scripts/00_install_tools_wsl.sh
aws configure

# ssh key
bash scripts/01_generate_ssh_key.sh

# infra
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
bash scripts/02_terraform_apply.sh

# secrets
cp ansible/group_vars/all/vault.yml.example ansible/group_vars/all/vault.yml
# set passwords, then
ansible-vault encrypt ansible/group_vars/all/vault.yml

# deploy
bash scripts/03_ansible_deploy.sh

# verify
bash scripts/04_verify.sh --write
```

Then open `http://<web_public_ip>` (`terraform output application_url`).

## Verify manually

```bash
IP=$(cd terraform && terraform output -raw web_public_ip)
curl http://$IP/api/health
curl http://$IP/api/trip
cd ansible && ansible-playbook verify.yml --ask-vault-pass
```

## Cleanup

```bash
bash scripts/99_destroy.sh
```

The NAT gateway and EIPs are billed hourly, so destroy when done.
