#!/bin/bash
#
# install-docker-compose.sh
# Script interactif pour installer Docker Compose v1.29.2
# Compatible : macOS (Catalina+), Linux (Debian/Ubuntu), Windows (WSL2/Git Bash/MinGW)
#

# --- Couleurs ---
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo -e "${YELLOW}🚀 Script d’installation de Docker Compose v1.29.2${NC}"

# --- Menu ---
echo -e "${YELLOW}Choisis ton système d’exploitation :${NC}"
echo "1) macOS"
echo "2) Linux (Debian/Ubuntu)"
echo "3) Windows (WSL2, Git Bash, MinGW)"
read -p "👉 Entrez le numéro correspondant [1-3] : " CHOICE

# --- Fonction installation ---
install_compose() {
    TARGET=$1
    OS=$2
    ARCH=$(uname -m)
    echo -e "${YELLOW}⬇️ Téléchargement de docker-compose v1.29.2...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-${OS}-${ARCH}" -o "$TARGET"
    sudo chmod +x "$TARGET"
}

# --- Cas macOS ---
if [[ "$CHOICE" == "1" ]]; then
    echo -e "${YELLOW}🍏 Installation pour macOS${NC}"
    TARGET="/usr/local/bin/docker-compose"
    install_compose "Darwin" "$TARGET"

# --- Cas Linux ---
elif [[ "$CHOICE" == "2" ]]; then
    echo -e "${YELLOW}🐧 Installation pour Linux Debian/Ubuntu${NC}"
    sudo apt-get update -y
    sudo apt-get install -y curl
    TARGET="/usr/local/bin/docker-compose"
    install_compose "Linux" "$TARGET"

# --- Cas Windows ---
elif [[ "$CHOICE" == "3" ]]; then
    echo -e "${YELLOW}🪟 Installation pour Windows (via WSL2/Git Bash/MinGW)${NC}"
    TARGET="/usr/bin/docker-compose.exe"
    ARCH=$(uname -m)
    echo -e "${YELLOW}⬇️ Téléchargement de docker-compose v1.29.2...${NC}"
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-$ARCH.exe" -o "$TARGET"
    chmod +x "$TARGET"

else
    echo -e "${RED}❌ Choix invalide. Relance le script et sélectionne 1, 2 ou 3.${NC}"
    exit 1
fi

# --- Vérification ---
if command -v docker-compose >/dev/null 2>&1; then
    VERSION=$(docker-compose --version)
    echo -e "${GREEN}✅ Docker Compose installé avec succès !${NC}"
    echo -e "${GREEN}👉 Version : $VERSION${NC}"
else
    echo -e "${RED}❌ Échec de l'installation. Vérifie manuellement.${NC}"
    exit 1
fi
