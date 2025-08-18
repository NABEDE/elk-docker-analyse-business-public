#!/bin/bash

# Script de création de l'architecture BI/ELK
# Version: 1.2
# Auteur: [Votre Nom]
# Description: Crée l'arborescence complète pour la plateforme BI avec Elastic Stack

# Fonction pour créer un répertoire avec vérification
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "✅ Répertoire créé: $1"
    else
        echo "⚠️ Le répertoire existe déjà: $1"
    fi
}

# Fonction pour créer un fichier de configuration vide
create_config_file() {
    if [ ! -f "$1" ]; then
        touch "$1"
        echo "# Configuration for ${2}" > "$1"
        echo "✅ Fichier config créé: $1"
    else
        echo "⚠️ Le fichier config existe déjà: $1"
    fi
}

# Fonction pour créer un fichier JSON vide (pour ML jobs et watchers)
create_json_config() {
    if [ ! -f "$1" ]; then
        echo '{
  "name": "'"${2}"'",
  "description": "'"${3}"'",
  "config": {}
}' > "$1"
        echo "✅ Fichier JSON créé: $1"
    else
        echo "⚠️ Le fichier JSON existe déjà: $1"
    fi
}

# Racine du projet
ROOT_DIR="business-intelligence"
echo "🏗️  Création de l'architecture dans: $ROOT_DIR"

# 1. Création de l'arborescence de base
#create_dir "$ROOT_DIR"
create_dir "$ROOT_DIR/config"
create_dir "$ROOT_DIR/data"
create_dir "$ROOT_DIR/data-generator"
create_dir "$ROOT_DIR/ml-jobs"
create_dir "$ROOT_DIR/watchers"
create_dir "$ROOT_DIR/scripts"

# 2. Configuration Logstash
LOGSTASH_DIR="$ROOT_DIR/config/logstash"
create_dir "$LOGSTASH_DIR"

# Fichiers de pipeline Logstash
create_config_file "$LOGSTASH_DIR/pipelines.yml" "Logstash Pipelines"
create_config_file "$LOGSTASH_DIR/sales-pipeline.conf" "Sales Pipeline"
create_config_file "$LOGSTASH_DIR/customers-pipeline.conf" "Customers Pipeline"
create_config_file "$LOGSTASH_DIR/finance-pipeline.conf" "Finance Pipeline"

# 3. Configuration Elasticsearch
ES_DIR="$ROOT_DIR/config/elasticsearch"
create_dir "$ES_DIR"
create_dir "$ES_DIR/index-templates"
create_dir "$ES_DIR/ilm-policies"

# 4. Configuration Kibana
KIBANA_DIR="$ROOT_DIR/config/kibana"
create_dir "$KIBANA_DIR"
create_dir "$KIBANA_DIR/dashboards"
create_dir "$KIBANA_DIR/canvas"

# Fichiers de dashboard Kibana (NDJSON)
create_config_file "$KIBANA_DIR/dashboards/executive-overview.ndjson" "Executive Overview Dashboard"
create_config_file "$KIBANA_DIR/dashboards/sales-analysis.ndjson" "Sales Analysis Dashboard"
create_config_file "$KIBANA_DIR/dashboards/customer-segmentation.ndjson" "Customer Segmentation Dashboard"
create_config_file "$KIBANA_DIR/canvas/executive-report.json" "Canvas Executive Report"

# 5. Répertoires de données
create_dir "$ROOT_DIR/data/sales"
create_dir "$ROOT_DIR/data/customers"
create_dir "$ROOT_DIR/data/finance"
create_dir "$ROOT_DIR/data/inventory"

# 6. Générateur de données
create_config_file "$ROOT_DIR/data-generator/generate-business-data.py" "Data Generator Script"
create_config_file "$ROOT_DIR/data-generator/simulate-real-time.py" "Real-time Data Simulator"

# 7. Jobs ML
create_json_config "$ROOT_DIR/ml-jobs/sales-forecast.json" "Sales Forecast" "Machine learning job for sales forecasting"
create_json_config "$ROOT_DIR/ml-jobs/customer-segmentation.json" "Customer Segmentation" "ML job for customer clustering"
create_json_config "$ROOT_DIR/ml-jobs/anomaly-detection.json" "Anomaly Detection" "Detect anomalies in financial data"

# 8. Alertes Watcher
create_json_config "$ROOT_DIR/watchers/revenue-alert.json" "Revenue Alert" "Alert when revenue drops below threshold"
create_json_config "$ROOT_DIR/watchers/stock-alert.json" "Stock Alert" "Alert when inventory stock is low"
create_json_config "$ROOT_DIR/watchers/customer-churn-alert.json" "Customer Churn Alert" "Alert when customer churn risk detected"

# 9. Scripts utilitaires
create_config_file "$ROOT_DIR/scripts/setup-bi.sh" "BI Setup Script"
create_config_file "$ROOT_DIR/scripts/import-data.sh" "Data Import Script"
create_config_file "$ROOT_DIR/scripts/create-ml-jobs.sh" "ML Jobs Creation Script"

# 10. Fichier docker-compose
DOCKER_COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    cat > "$DOCKER_COMPOSE_FILE" << 'EOL'
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.4.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    volumes:
      - ./config/elasticsearch:/usr/share/elasticsearch/config
    ports:
      - "9200:9200"
    networks:
      - bi-network

  kibana:
    image: docker.elastic.co/kibana/kibana:8.4.0
    depends_on:
      - elasticsearch
    volumes:
      - ./config/kibana:/usr/share/kibana/config
    ports:
      - "5601:5601"
    networks:
      - bi-network

  logstash:
    image: docker.elastic.co/logstash/logstash:8.4.0
    depends_on:
      - elasticsearch
    volumes:
      - ./config/logstash:/usr/share/logstash/config
      - ./data:/data
    ports:
      - "5044:5044"
    networks:
      - bi-network

networks:
  bi-network:
    driver: bridge
EOL
    echo "✅ Fichier docker-compose.yml créé avec configuration de base"
else
    echo "⚠️ Le fichier docker-compose.yml existe déjà"
fi

# Rendre les scripts exécutables
chmod +x "$ROOT_DIR/scripts/"*.sh
chmod +x "$ROOT_DIR/data-generator/"*.py

echo "✨ Architecture BI créée avec succès!"
echo "📌 Pour démarrer l'environnement: cd $ROOT_DIR && docker-compose up -d"