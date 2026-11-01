#!/usr/bin/env bash
set -euo pipefail

KEY="${1:-$HOME/.ssh/travelmemory-key}"

if [[ -f "$KEY" ]]; then
  echo "Key already exists: $KEY"
else
  mkdir -p "$(dirname "$KEY")"
  chmod 700 "$(dirname "$KEY")"
  ssh-keygen -t ed25519 -a 100 -C "travelmemory-$(date +%Y%m%d)" -f "$KEY" -N ""
  echo "Created $KEY and $KEY.pub"
fi

chmod 600 "$KEY"
chmod 644 "$KEY.pub"
cat "$KEY.pub"
