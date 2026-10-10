#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Información del Sistema Operativo y Distribución
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🏷️ SISTEMA OPERATIVO Y DISTRIBUCIÓN" "Detalles de la versión de GNU/Linux instalada"

imprimir_resumen_distro
echo

echo -e "${BOLD}⚙️  Detalles de la Plataforma:${RESET}"
echo -e "   • Núcleo (Kernel):  ${CYAN}$(uname -srm)${RESET}"
echo -e "   • Escritorio (DE):  ${GREEN}${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-N/A}}${RESET}"
echo -e "   • Servidor Gráfico: ${YELLOW}${XDG_SESSION_TYPE:-N/A}${RESET}"
echo -e "   • Tiempo encendido: ${MAGENTA}$(uptime -p 2>/dev/null || uptime)${RESET}"

if command -v lsb_release >/dev/null 2>&1; then
    echo
    echo -e "${BOLD}Detalles LSB:${RESET}"
    lsb_release -a 2>/dev/null
fi

pausar
