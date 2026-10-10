#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Limpiar archivo de MACs registradas
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🧹 VACIAR REGISTRO DE MACS" "Elimina la lista acumulada de direcciones MAC del laboratorio"

if [[ ! -f "$ARCHIVO_MACS" ]]; then
    imprimir_info "El archivo $ARCHIVO_MACS no existe o ya está vacío."
    touch "$ARCHIVO_MACS"
    pausar
    exit 0
fi

CANTIDAD=$(wc -l < "$ARCHIVO_MACS" 2>/dev/null || echo 0)
echo -e "Actualmente hay ${BOLD}$CANTIDAD${RESET} direcciones registradas en:"
echo -e "${CYAN}$ARCHIVO_MACS${RESET}"
echo

echo -ne "${BOLD}${RED}¿Está seguro de que desea vaciar el archivo? (s/N): ${RESET}"
read -r respuesta

if [[ "$respuesta" =~ ^[sS]$ ]]; then
    > "$ARCHIVO_MACS"
    imprimir_exito "El archivo de MACs ha sido vaciado exitosamente."
else
    imprimir_info "Operación cancelada. El archivo se mantiene intacto."
fi

pausar
