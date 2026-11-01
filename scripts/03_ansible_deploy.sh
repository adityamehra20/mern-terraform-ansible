#!/usr/bin/env bash
# usage: 03_ansible_deploy.sh [playbook] [extra args]
set -euo pipefail
cd "$(dirname "$0")/../ansible"

PLAYBOOK="${1:-site.yml}"
shift || true

# ansible.cfg is ignored in world-writable dirs like /mnt/c
export ANSIBLE_CONFIG="$PWD/ansible.cfg"

if [[ ! -f inventory/hosts.yml ]]; then
  echo "inventory/hosts.yml not found, run terraform first" >&2
  exit 1
fi

if [[ ! -f group_vars/all/vault.yml ]]; then
  echo "group_vars/all/vault.yml not found (copy vault.yml.example and encrypt it)" >&2
  exit 1
fi

VAULT_ARGS=()
if head -1 group_vars/all/vault.yml | grep -q '^\$ANSIBLE_VAULT'; then
  if [[ -f "$HOME/.travelmemory_vault_pass" ]]; then
    VAULT_ARGS=(--vault-password-file "$HOME/.travelmemory_vault_pass")
  else
    VAULT_ARGS=(--ask-vault-pass)
  fi
else
  echo "warning: vault.yml is not encrypted" >&2
fi

ansible-inventory --graph
ansible-playbook "$PLAYBOOK" --syntax-check "${VAULT_ARGS[@]}"
ansible all -m ping "${VAULT_ARGS[@]}"
ansible-playbook "$PLAYBOOK" "${VAULT_ARGS[@]}" "$@"
