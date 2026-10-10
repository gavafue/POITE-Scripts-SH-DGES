#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Información de Memoria RAM y Swap
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🪫 INFORMACIÓN DE MEMORIA RAM Y SWAP" "Estado de memoria física, memoria disponible y área de intercambio"

echo -e "${BOLD}Resumen de Memoria:${RESET}"
echo "----------------------------------------------------------------------"
free -h --wide 2>/dev/null || free -h
echo "----------------------------------------------------------------------"

# Calcular porcentaje de uso
if command -v free >/dev/null 2>&1; then
    TOTAL_RAM=$(free -m | awk '/Mem:/ {print $2}')
    USADA_RAM=$(free -m | awk '/Mem:/ {print $3}')
    if [[ -n "$TOTAL_RAM" && "$TOTAL_RAM" -gt 0 ]]; then
        PORCENTAJE=$(( USADA_RAM * 100 / TOTAL_RAM ))
        echo
        echo -e "• Uso de RAM actual: ${BOLD}${PORCENTAJE}%${RESET} (${USADA_RAM} MB de ${TOTAL_RAM} MB)"
        if (( PORCENTAJE > 85 )); then
            imprimir_aviso "Uso elevado de memoria RAM. Considere cerrar aplicaciones pesadas."
        else
            imprimir_exito "Nivel de memoria RAM adecuado para el laboratorio."
        fi
    fi
fi

pausar