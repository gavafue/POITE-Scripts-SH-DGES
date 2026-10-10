#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Información del Sistema Operativo y Distribución
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🏷️ SISTEMA OPERATIVO Y DISTRIBUCIÓN" "Detalles de la versión de GNU/Linux instalada"

if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo -e "• Distribución:     ${BOLD}${CYAN}${PRETTY_NAME:-$NAME}${RESET}"
    echo -e "• Versión:          ${GREEN}${VERSION:-N/A}${RESET}"
    echo -e "• Codename:         ${YELLOW}${VERSION_CODENAME:-${UBUNTU_CODENAME:-N/A}}${RESET}"
    echo -e "• ID Base:          ${MAGENTA}${ID_LIKE:-$ID}${RESET}"
    echo -e "• Sitio web:        ${BLUE}${HOME_URL:-N/A}${RESET}"
    echo
fi

if command -v lsb_release >/dev/null 2>&1; then
    echo -e "${BOLD}Detalles LSB:${RESET}"
    lsb_release -a 2>/dev/null
    echo
fi

echo -e "• Tiempo encendido (Uptime): $(uptime -p 2>/dev/null || uptime)"

pausar
