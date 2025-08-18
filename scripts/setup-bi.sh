#! /bin/bash


# ======= Variable ==========
HOST_ELASTICSEARCH=http://localhost:9200
HOST_KIBANA=http://localhost:5601

TYPE="sales"

# Les couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'


error() {
    local message="$1"
    echo -e "${RED}❌ ERREUR : ${message}${RESET}" 1>&2
}

check_container_running() {
    local container_name="$1"
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        error "Le conteneur ${container_name} n'est pas en cours d'exécution"
        return 1
    fi
}




# ====== Les fonctions ===========

verification_elasticsearch_fonction()
{
    echo "Vérification si elasticsearch fonctionne bien ou pas"
    curl -X GET http://localhost:9200/
}

add_index_mapp_elasticsearch() {
    local INDEX_NAME="sales_data"
    local FILE_JSON="add-bi/sales_mapping.json"  # ou autre chemin approprié

    echo "Ajout de l'index et du mapping dans Elasticsearch..."

    if [[ ! -f "$FILE_JSON" ]]; then
        echo "Erreur : le fichier JSON '$FILE_JSON' est introuvable."
        return 1
    fi

    curl -X PUT "http://localhost:9200/${INDEX_NAME}" \
        -H "Content-Type: application/json" \
        -d @"${FILE_JSON}"

    echo -e "\nMapping appliqué à l'index '${INDEX_NAME}'"
}



send_data_for_filter_logstash() {
    local TYPE="$1"

    local CSV_FILE="../data/${TYPE}/${TYPE}_data.csv"
    local LOGSTASH_CONF="../config/logstash/${TYPE}-pipeline.conf"
    local PIPELINE_YML="../config/logstash/pipelines.yml"
    local LOGSTASH_CONTAINER="logstash"
    local JSON_FILE="${TYPE}.json"
    local CONTAINER_PATH="/usr/share/logstash/data/json/${JSON_FILE}"
    local LOCAL_DEST="../data/${TYPE}/json/${JSON_FILE}"

    echo -e "\n${GREEN}==> Étape 1 : Vérification des fichiers requis${RESET}"
    if [[ ! -f "$CSV_FILE" ]]; then
        error "Fichier CSV manquant : $CSV_FILE"
        return 1
    fi

    if [[ ! -f "$LOGSTASH_CONF" ]]; then
        error "Pipeline de configuration manquant : $LOGSTASH_CONF"
        return 1
    fi

    if [[ ! -f "$PIPELINE_YML" ]]; then
        error "Fichier pipelines.yml manquant : $PIPELINE_YML"
        return 1
    fi

    echo -e "${GREEN}==> Étape 2 : Vérification que le conteneur Logstash est actif${RESET}"
    check_container_running "$LOGSTASH_CONTAINER" || return 1

    echo -e "${GREEN}==> Étape 3 : Copie du fichier CSV dans le conteneur Logstash${RESET}"
    docker exec "$LOGSTASH_CONTAINER" mkdir -p "/usr/share/logstash/data/${TYPE}" || {
        error "Impossible de créer le dossier cible dans le conteneur Logstash"
        return 1
    }


    echo -e "${GREEN}==> Étape 4 : Redémarrage de Logstash pour prise en compte du pipeline${RESET}"
    docker restart "$LOGSTASH_CONTAINER" > /dev/null

    # Attente du fichier JSON généré
    echo -e "${GREEN}==> Vérification : données JSON générées ?${RESET}"
    docker exec "$LOGSTASH_CONTAINER" bash -c 'while [ ! -f /usr/share/logstash/data/sales.json ]; do sleep 1; done'

    # Affichage des premières lignes
    echo -e "${GREEN}==> Aperçu des données filtrées :${RESET}"
    docker exec "$LOGSTASH_CONTAINER" cat /usr/share/logstash/data/sales.json | head -n 10


    echo -e "${GREEN}==> Étape 5 : Attente de génération du fichier JSON dans le conteneur...${RESET}"

    MAX_WAIT=30
    SECONDS_WAITED=0

    while true; do
        if docker exec "$LOGSTASH_CONTAINER" test -f "$CONTAINER_PATH"; then
            echo -e "${GREEN}✅ Fichier JSON détecté : $CONTAINER_PATH${RESET}"
            break
        fi

        if ! docker ps --format '{{.Names}}' | grep -q "^${LOGSTASH_CONTAINER}$"; then
            echo -e "${RED}❌ Le conteneur Logstash est arrêté ou introuvable${RESET}"
            return 1
        fi

        sleep 1
        ((SECONDS_WAITED++))

        if (( SECONDS_WAITED % 5 == 0 )); then
            echo -e "${YELLOW}... attente en cours : ${SECONDS_WAITED}s${RESET}"
        fi

        if (( SECONDS_WAITED >= MAX_WAIT )); then
            echo -e "${RED}❌ Timeout : Le fichier JSON n'a pas été généré après ${MAX_WAIT} secondes${RESET}"
            echo -e "${YELLOW}💡 Vérifie le chemin dans la conf Logstash et les logs avec : docker logs logstash${RESET}"
            return 1
        fi
    done

}


send_data_for_filter_logstash "sales"


