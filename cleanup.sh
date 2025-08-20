#!/bin/bash
echo "🧹 Nettoyage Docker en cours..."
docker compose down -v
docker container prune -f
docker volume prune -f
docker image prune -a -f
docker network prune -f
echo "✅ Docker nettoyé !"
