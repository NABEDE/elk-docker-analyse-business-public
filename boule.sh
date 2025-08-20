#!/bin/bash

# Nom des services à surveiller
services=("elasticsearch" "logstash" "kibana")

# Intervalle entre les vérifications (en secondes)
interval=60

echo "🔄 Surveillance du stack ELK toutes les $interval secondes..."

while true; do
  restart_needed=false

  for service in "${services[@]}"; do
    status=$(docker inspect -f '{{.State.Health.Status}}' "$service" 2>/dev/null)

    if [[ "$status" != "healthy" ]]; then
      echo "⚠️  Service $service n'est pas healthy (état: $status)"
      restart_needed=true
    else
      echo "✅ $service est healthy"
    fi
  done

  if $restart_needed; then
    echo "🔁 Redémarrage du stack ELK..."
    docker-compose down -v
    docker-compose up -d
  fi

  sleep "$interval"
done
