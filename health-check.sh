#!/bin/bash
set -e

echo "🔍 Checking PMM & Watchtower Container Status..."

check_container_health() {
  local name="$1"
  local display="$2"

  status=$(docker inspect -f '{{.State.Status}}' "$name" 2>/dev/null || echo "not found")
  health=$(docker inspect -f '{{.State.Health.Status}}' "$name" 2>/dev/null || echo "unknown")

  if [[ "$status" == "running" && "$health" == "healthy" ]]; then
    echo "✅ $display is running and healthy"
  elif [[ "$status" == "running" ]]; then
    echo "⚠️  $display is running but health: $health"
  else
    echo "❌ $display not running (status: $status)"
  fi
}

# PMM Server
check_container_health "pmm-server-prod" "PMM Server"

# Watchtower
check_container_health "watchtower-prod" "Watchtower"

echo
echo "🔍 Checking PMM Web & API Endpoints..."

# PMM Web (port 443 → 8443)
curl -sk https://localhost:443 | grep -iq "html" \
  && echo "✅ PMM Web reachable (HTTPS 443)" \
  || echo "❌ PMM Web not reachable (HTTPS 443)"

# Watchtower API (port 8080)
curl -s http://localhost:8080 | grep -iq "watchtower" \
  && echo "✅ Watchtower API reachable (HTTP 8080)" \
  || echo "⚠️  Watchtower API not returning expected output (non-critical)"

echo
echo "🔍 Checking Recent PMM Logs..."

docker logs pmm-server-prod --tail 50 2>/dev/null | grep -i "error" \
  && echo "❌ Errors found in PMM logs" \
  || echo "✅ No critical errors in PMM logs"

echo
echo "✅ Health check completed."
