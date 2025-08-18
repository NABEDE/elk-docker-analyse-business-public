#!/bin/bash

# === CONFIGURATION ===
SCRIPT_PATH="./scripts/setup-bi.sh"
ES_URL="http://localhost:9200"
WAIT_TIMEOUT=60

# === LANCEMENT DOCKER-COMPOSE ===
echo "🚀 Lancement de l'environnement BI avec Docker Compose..."
docker-compose up -d
if [ $? -eq 0 ]; then
    echo "✅ Environnement Docker lancé avec succès."
else
    echo "❌ Échec du lancement de Docker Compose."
    exit 1
fi

# === CHMOD DU SCRIPT ===
echo "🔐 Application des droits d'exécution sur $SCRIPT_PATH..."
chmod +x "$SCRIPT_PATH"
if [ $? -eq 0 ]; then
    echo "✅ Droits appliqués sur $SCRIPT_PATH."
else
    echo "❌ Échec de l'application des droits sur $SCRIPT_PATH."
    exit 1
fi

# === ATTENTE DE ELASTICSEARCH ===
echo "⏳ Attente que Elasticsearch soit prêt sur $ES_URL..."

for ((i=1; i<=WAIT_TIMEOUT; i++)); do
    status=$(curl -s "$ES_URL/_cluster/health" | grep -o '"status":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    if [[ "$status" == "green" || "$status" == "yellow" ]]; then
        echo "✅ Elasticsearch est prêt (status: $status)."
        break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq $WAIT_TIMEOUT ]; then
        echo "❌ Timeout atteint : Elasticsearch ne répond pas après $WAIT_TIMEOUT secondes."
        exit 1
    fi
done

# === EXECUTION DU SETUP-BI.SH ===
echo "⚙️ Lancement du script de setup initial BI..."
bash "$SCRIPT_PATH"
if [ $? -eq 0 ]; then
    echo "✅ Setup BI exécuté avec succès."
else
    echo "❌ Échec lors de l'exécution de $SCRIPT_PATH."
    exit 1
fi

# === FIN ===
echo "🎉 Mise en place de l'environnement BI terminée avec succès."
