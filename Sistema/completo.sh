#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Auditoría Completa del Sistema
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📋 AUDITORÍA COMPLETA DEL SISTEMA" "Resumen de Kernel, Sistema Operativo, CPU, Memoria y Discos"

echo -e "${BOLD}${BLUE}=== 1. KERNEL ===${RESET}"
uname -srm
echo

echo -e "${BOLD}${BLUE}=== 2. SISTEMA OPERATIVO ===${RESET}"
if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "$PRETTY_NAME ($ID)"
fi
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo

echo -e "${BOLD}${BLUE}=== 3. PROCESADOR (CPU) ===${RESET}"
lscpu 2>/dev/null | grep -E "Model name|Architecture|CPU\(s\):|CPU max MHz" || grep -m1 "model name" /proc/cpuinfo
echo

echo -e "${BOLD}${BLUE}=== 4. MEMORIA RAM ===${RESET}"
free -h
echo

echo -e "${BOLD}${BLUE}=== 5. ALMACENAMIENTO ===${RESET}"
df -h -x tmpfs -x devtmpfs -x squashfs 2>/dev/null || df -h
echo

echo -e "${BOLD}${BLUE}=== 6. RED ===${RESET}"
echo "IP Local: $(obtener_ip_local)"
echo "Interfaz: $(obtener_interfaz_activa)"

pausar