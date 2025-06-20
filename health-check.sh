#!/bin/bash
set -e
echo "🔍 Checking PMM Status..."
docker inspect -f '{{.State.Status}}' pmm-server-prod
curl -sk https://localhost:443 | grep -q "html" && echo "✅ PMM Web reachable" || echo "❌ PMM Web not reachable"
docker ps --filter "name=pmm-server-prod" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep "pmm-server-prod" || echo "❌ PMM Server not running"
docker logs pmm-server-prod --tail 10 | grep -i "error" && echo "❌ Errors found in PMM logs" || echo "✅ No errors in PMM logs"
echo "🔍 Checking PMM Services..." 
docker exec pmm-server-prod pmm-admin list | grep -q "mysql" && echo "✅ MySQL service found" || echo "❌ MySQL service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "mongodb" && echo "✅ MongoDB service found" || echo "❌ MongoDB service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "postgresql" && echo "✅ PostgreSQL service found" || echo "❌ PostgreSQL service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "redis" && echo "✅ Redis service found" || echo "❌ Redis service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "nginx" && echo "✅ Nginx service found" || echo "❌ Nginx service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "node_exporter" && echo "✅ Node Exporter service found" || echo "❌ Node Exporter service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "blackbox_exporter" && echo "✅ Blackbox Exporter service found" || echo "❌ Blackbox Exporter service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "alertmanager" && echo "✅ Alertmanager service found" || echo "❌ Alertmanager service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "prometheus" && echo "✅ Prometheus service found" || echo "❌ Prometheus service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "grafana" && echo "✅ Grafana service found" || echo "❌ Grafana service not found"
docker exec pmm-server-prod pmm-admin list | grep -q "pmm-agent" && echo "✅ PMM Agent service  found" || echo "❌ PMM Agent service not found"
echo "🔍 Checking PMM Metrics..."

