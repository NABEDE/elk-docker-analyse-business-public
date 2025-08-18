#!/bin/bash

# === Variables couleurs ===
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# === Fonctions utilitaires ===
success() {
    echo -e "${GREEN}[OK] $1${RESET}"
}

error() {
    echo -e "${RED}[ERREUR] $1${RESET}"
}

# === Vérification de l’indexation dans Elasticsearch ===
verify_ingestion() {
    local index_name=$1
    local count

    echo "Vérification de l’index [$index_name] dans Elasticsearch..."

    count=$(curl -s "http://localhost:9200/${index_name}/_count" | jq -r '.count')

    if [[ "$count" =~ ^[0-9]+$ && "$count" -gt 0 ]]; then
        success "Index [$index_name] contient $count documents."
    else
        error "Aucune donnée trouvée dans l’index [$index_name]."
    fi
}

# === Ingestion des données ===
ingest_data() {
    TYPE="$1"
    DATA_DIR="../data/${TYPE}"
    PIPELINE_CONF="../config/logstash/${TYPE}-pipeline.conf"
    CONTAINER_NAME="logstash"
    INDEX_NAME="${TYPE}-data"

    echo -e "${GREEN}>> Ingestion des données : ${TYPE}${RESET}"

    # Vérifications de base
    if [[ ! -d "$DATA_DIR" ]]; then
        error "Dossier de données manquant : $DATA_DIR"
        return
    fi

    if [[ ! -f "$PIPELINE_CONF" ]]; then
        error "Pipeline Logstash manquant : $PIPELINE_CONF"
        return
    fi

    # Copie des fichiers
    echo "Copie des fichiers depuis $DATA_DIR..."
    docker cp "$DATA_DIR/." "$CONTAINER_NAME:/usr/share/logstash/data/${TYPE}/" || {
        error "Échec de la copie des données."
        return
    }

    # Redémarrage de Logstash pour appliquer le pipeline
    echo "Redémarrage de Logstash..."
    docker restart "$CONTAINER_NAME" > /dev/null

    # Attente pour ingestion (5 à 10 sec)
    echo "Attente de l’indexation (10 sec)..."
    sleep 10

    # Vérification via Elasticsearch
    verify_ingestion "$INDEX_NAME"
}


# === MENU ===
show_menu() {
    while true; do
        echo -e "\n${GREEN}=== SETUP INGESTION ELK BI ===${RESET}"
        echo "1) Ingestion ventes (sales)"
        echo "2) Ingestion clients (customers)"
        echo "3) Ingestion finances (finance)"
        echo "4) Ingestion inventaire (inventory)"
        echo "0) Quitter"
        echo -n "Votre choix : "
        read -r choix

        case $choix in
            1) ingest_data "sales" ;;
            2) ingest_data "customers" ;;
            3) ingest_data "finance" ;;
            4) ingest_data "inventory" ;;
            0) echo "Sortie..."; exit 0 ;;
            *) error "Choix invalide. Veuillez réessayer." ;;
        esac
    done
}

# === POINT D'ENTRÉE ===
show_menu
