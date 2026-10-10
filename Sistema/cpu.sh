#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Información detallada de CPU / Procesador
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🧠 INFORMACIÓN DEL PROCESADOR (CPU)" "Arquitectura, núcleos, modelo y frecuencia de procesamiento"

echo -e "${BOLD}Resumen de la CPU:${RESET}"
echo "----------------------------------------------------------------------"
MODELO=$(lscpu 2>/dev/null | grep -i "Model name" | cut -d: -f2 | xargs || grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
ARQ=$(lscpu 2>/dev/null | grep -i "Architecture" | cut -d: -f2 | xargs || uname -m)
CORES=$(lscpu 2>/dev/null | grep -i "^CPU(s):" | cut -d: -f2 | xargs || nproc)
HILOS_POR_NUCLEO=$(lscpu 2>/dev/null | grep -i "Thread(s) per core" | cut -d: -f2 | xargs || echo "1")
FREQ_MAX=$(lscpu 2>/dev/null | grep -i "CPU max MHz" | cut -d: -f2 | xargs || echo "N/A")
VIRT=$(lscpu 2>/dev/null | grep -i "Virtualization" | cut -d: -f2 | xargs || echo "No detectada")

echo -e "• Modelo:          ${CYAN}${MODELO:-Desconocido}${RESET}"
echo -e "• Arquitectura:    ${GREEN}$ARQ${RESET}"
echo -e "• Núcleos/Hilos:   ${YELLOW}$CORES totales ($HILOS_POR_NUCLEO por núcleo)${RESET}"
echo -e "• Frecuencia máx:  $FREQ_MAX MHz"
echo -e "• Virtualización:  $VIRT"
echo "----------------------------------------------------------------------"

echo
echo -e "${BOLD}Detalle completo (lscpu):${RESET}"
lscpu 2>/dev/null | head -n 25

pausar