#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Limpieza profunda de almacenamiento y liberación de espacio en disco
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🧹 LIMPIEZA PROFUNDA DE ALMACENAMIENTO" "Libera espacio eliminando cachés temporales, registros antiguos y paquetes"

echo -e "Espacio inicial en disco (/): ${BOLD}$(df -h / | awk 'NR==2 {print $4 " libres"}') ${RESET}"
echo

if ! asegurar_root; then
    exit 1
fi

echo -e "${CYAN}1. Limpiando caché de paquetes APT descargados...${RESET}"
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove --purge -y

echo
echo -e "${CYAN}2. Reduciendo tamaño de registros del sistema (journalctl)...${RESET}"
sudo journalctl --vacuum-time=7d 2>/dev/null || true
sudo journalctl --vacuum-size=100M 2>/dev/null || true

echo
echo -e "${CYAN}3. Limpiando miniaturas (thumbnails) y cachés temporales de usuarios...${RESET}"
rm -rf /home/*/.cache/thumbnails/* 2>/dev/null || true
rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
sudo rm -rf /var/crash/* 2>/dev/null || true

echo
imprimir_exito "Limpieza profunda finalizada con éxito."
echo -e "Espacio final en disco (/): ${BOLD}${GREEN}$(df -h / | awk 'NR==2 {print $4 " libres"}') ${RESET}"

pausar
