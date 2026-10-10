#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Información de Almacenamiento y Discos
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "💽 INFORMACIÓN DE DISCOS Y PARTICIONES" "Puntos de montaje, tipos de sistema de archivos y espacio disponible"

echo -e "${BOLD}1. Dispositivos de bloque y particiones:${RESET}"
echo "----------------------------------------------------------------------"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT 2>/dev/null || lsblk
echo "----------------------------------------------------------------------"
echo

echo -e "${BOLD}2. Ocupación de sistemas de archivos montados:${RESET}"
echo "----------------------------------------------------------------------"
df -h -x tmpfs -x devtmpfs -x squashfs 2>/dev/null || df -h
echo "----------------------------------------------------------------------"

pausar