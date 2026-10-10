#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Información del Kernel Linux
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🧩 INFORMACIÓN DEL KERNEL LINUX" "Versión del núcleo, arquitectura y fecha de compilación"

echo -e "• Versión del Kernel:    ${BOLD}${GREEN}$(uname -r)${RESET}"
echo -e "• Arquitectura:          ${BOLD}${CYAN}$(uname -m)${RESET}"
echo -e "• Nombre del Host:       ${BOLD}${YELLOW}$(uname -n)${RESET}"
echo -e "• Fecha de Compilación:  $(uname -v)"
echo
echo -e "${BOLD}Salida completa (uname -a):${RESET}"
uname -a

pausar