#!/usr/bin/env bash
# usage: 04_verify.sh [--write]
set -euo pipefail
cd "$(dirname "$0")/.."

IP="${WEB_IP:-}"
[[ -z "$IP" && -f ansible/inventory/hosts.yml ]] && IP=$(grep -m1 'web_public_ip:' ansible/inventory/hosts.yml | awk '{print $2}')
[[ -z "$IP" ]] && IP="$(cd terraform && terraform output -raw web_public_ip)"
BASE="http://$IP"
WRITE="${1:-}"
count_json() { python3 -c 'import sys,json; print(len(json.load(sys.stdin)))'; }

pass() { echo "  ok   $*"; }
fail() { echo "  FAIL $*"; exit 1; }

echo "Target: $BASE"

echo "frontend"
code=$(curl -s -o /tmp/tm_index.html -w '%{http_code}' "$BASE/")
[[ "$code" == "200" ]] && grep -q 'id="root"' /tmp/tm_index.html && pass "GET / $code" || fail "GET / $code"

echo "health"
health=$(curl -s "$BASE/api/health")
echo "$health" | grep -q '"db":"connected"' && pass "$health" || fail "$health"

echo "trips"
before=$(curl -s "$BASE/api/trip" | count_json)
pass "$before trips"

if [[ "$WRITE" == "--write" ]]; then
  echo "create trip"
  resp=$(curl -s -w '\n%{http_code}' -H 'Content-Type: application/json' -X POST "$BASE/api/trip" -d '{
    "tripName": "Test trip",
    "startDateOfJourney": "2026-01-10",
    "endDateOfJourney": "2026-01-15",
    "nameOfHotels": "Test Hotel",
    "placesVisited": "Mumbai",
    "totalCost": 12345,
    "tripType": "leisure",
    "experience": "test entry",
    "shortDescription": "test",
    "featured": true
  }')
  code=$(echo "$resp" | tail -1)
  [[ "$code" == "201" ]] && pass "POST $code" || fail "POST $code: $(echo "$resp" | head -n -1)"
  after=$(curl -s "$BASE/api/trip" | count_json)
  [[ "$after" -gt "$before" ]] && pass "$before -> $after trips" || fail "count did not increase"
fi

echo "port 3001 closed"
if curl -s -m 5 "http://$IP:3001/health" >/dev/null 2>&1; then
  fail "port 3001 is open"
else
  pass "not reachable"
fi

curl -sI "$BASE/" | grep -iE 'x-frame-options|x-content-type-options|server:'
