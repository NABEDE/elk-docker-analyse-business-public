#!/bin/bash
set -euo pipefail

#######################################################################
# Script de setup pour l’ingestion de données BI avec ELK & Logstash  #
# Usage : ./scripts/setup-bi.sh [type]                                #
# Par défaut, TYPE="sales"                                            #
#######################################################################

# ==================== Configuration ====================
HOST_ELASTICSEARCH="http://localhost:9200"
HOST_KIBANA="http://localhost:5601"
TYPE="${1:-sales}"

INDEX_NAME="${TYPE}_data"
MAPPING_FILE="add-bi/${TYPE}_mapping.json"
CSV_FILE="../data/${TYPE}/${TYPE}_data.csv"
LOGSTASH_CONF="../config/logstash/${TYPE}-pipeline.conf"
PIPELINE_YML="../config/logstash/pipelines.yml"
LOGSTASH_CONTAINER="logstash"
JSON_FILE="${TYPE}.json"
CONTAINER_PATH="/usr/share/logstash/data/json/${JSON_FILE}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# ==================== Fonctions utilitaires ====================
log_info() {
    echo -e "${GREEN}ℹ️  $1${RESET}"
}
log_warn() {
    echo -e "${YELLOW}⚠️  $1${RESET}"
}
log_error() {
    echo -e "${RED}❌ $1${RESET}" 1>&2
}

# Vérifie la présence d'une commande
check_cmd() {
    command -v "$1" >/dev/null 2>&1 || { log_error "Commande '$1' manquante."; exit 1; }
}

# Vérifie si un conteneur docker tourne
check_container_running() {
    local container_name="$1"
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log_error "Le conteneur ${container_name} n'est pas en cours d'exécution"
        exit 1
    fi
}

# ==================== Pré-requis & Vérifications ====================
log_info "Vérification des dépendances..."
for cmd in docker curl; do
    check_cmd "$cmd"
done

if [[ ! -f "$MAPPING_FILE" ]]; then
    log_error "Fichier de mapping JSON introuvable : $MAPPING_FILE"
    exit 1
fi
if [[ ! -f "$CSV_FILE" ]]; then
    log_error "Fichier CSV manquant : $CSV_FILE"
    exit 1
fi
if [[ ! -f "$LOGSTASH_CONF" ]]; then
    log_error "Pipeline Logstash manquant : $LOGSTASH_CONF"
    exit 1
fi
if [[ ! -f "$PIPELINE_YML" ]]; then
    log_error "Fichier pipelines.yml manquant : $PIPELINE_YML"
    exit 1
fi

# ==================== Elasticsearch ====================
log_info "Vérification d'Elasticsearch..."
if ! curl -s "${HOST_ELASTICSEARCH}" | grep -q "cluster_name"; then
    log_error "Elasticsearch ne répond pas sur ${HOST_ELASTICSEARCH}"
    exit 1
fi

log_info "Création/Mise à jour de l'index '${INDEX_NAME}' sur Elasticsearch..."
response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "${HOST_ELASTICSEARCH}/${INDEX_NAME}" \
    -H "Content-Type: application/json" \
    -d @"${MAPPING_FILE}")

if [[ "$response" != "200" && "$response" != "201" ]]; then
    log_warn "L'index n'a pas pu être créé ou existe déjà (code HTTP: $response)"
else
    log_info "Mapping appliqué à l'index '${INDEX_NAME}'"
fi

# ==================== Logstash ====================
check_container_running "$LOGSTASH_CONTAINER"

log_info "Création du dossier cible dans le conteneur Logstash..."
docker exec "$LOGSTASH_CONTAINER" mkdir -p "/usr/share/logstash/data/${TYPE}" || {
    log_error "Impossible de créer le dossier cible dans le conteneur Logstash"
    exit 1
}

log_info "Copie du fichier CSV dans le conteneur Logstash..."
docker cp "$CSV_FILE" "$LOGSTASH_CONTAINER:/usr/share/logstash/data/${TYPE}/"

log_info "Redémarrage de Logstash pour prise en compte du pipeline..."
docker restart "$LOGSTASH_CONTAINER" > /dev/null

# ========== Attente du JSON généré par Logstash ==========
log_info "Attente de génération du fichier JSON dans le conteneur (timeout 30s)..."
MAX_WAIT=30
SECONDS_WAITED=0

while true; do
    if docker exec "$LOGSTASH_CONTAINER" test -f "$CONTAINER_PATH"; then
        log_info "Fichier JSON détecté : $CONTAINER_PATH"
        break
    fi

    if ! docker ps --format '{{.Names}}' | grep -q "^${LOGSTASH_CONTAINER}$"; then
        log_error "Le conteneur Logstash est arrêté ou introuvable"
        exit 1
    fi

    sleep 1
    ((SECONDS_WAITED++))

    if (( SECONDS_WAITED % 5 == 0 )); then
        log_warn "... attente en cours : ${SECONDS_WAITED}s"
    fi

    if (( SECONDS_WAITED >= MAX_WAIT )); then
        log_error "Timeout : Le fichier JSON n'a pas été généré après ${MAX_WAIT} secondes"
        log_warn "💡 Vérifie le chemin dans la conf Logstash et les logs avec : docker logs logstash"
        exit 1
    fi
done

# ========== Aperçu des données ==========
log_info "Aperçu des 10 premières lignes du JSON généré :"
docker exec "$LOGSTASH_CONTAINER" head -n 10 "$CONTAINER_PATH" || log_warn "Impossible d'afficher l'aperçu"

log_info "Setup BI terminé avec succès pour le type '${TYPE}'."

exit 0