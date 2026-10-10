#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Limpiar archivo de IPs registradas
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🧹 VACIAR REGISTRO DE IPS" "Elimina la lista acumulada de direcciones IP del laboratorio"

if [[ ! -f "$ARCHIVO_IPS" ]]; then
    imprimir_info "El archivo $ARCHIVO_IPS no existe o ya está vacío."
    touch "$ARCHIVO_IPS"
    pausar
    exit 0
fi

CANTIDAD=$(wc -l < "$ARCHIVO_IPS" 2>/dev/null || echo 0)
echo -e "Actualmente hay ${BOLD}$CANTIDAD${RESET} direcciones registradas en:"
echo -e "${CYAN}$ARCHIVO_IPS${RESET}"
echo

echo -ne "${BOLD}${RED}¿Está seguro de que desea vaciar el archivo? (s/N): ${RESET}"
read -r respuesta

if [[ "$respuesta" =~ ^[sS]$ ]]; then
    > "$ARCHIVO_IPS"
    imprimir_exito "El archivo de IPs ha sido vaciado exitosamente."
else
    imprimir_info "Operación cancelada. El archivo se mantiene intacto."
fi

pausar