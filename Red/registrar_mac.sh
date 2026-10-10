#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Registrar dirección MAC del equipo actual
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🏷️ REGISTRAR DIRECCIÓN MAC DEL EQUIPO" "Identificación de hardware de red para control por ARP y DHCP"

echo "🔍 Detectando interfaces de red disponibles..."
mapfile -t interfaces < <(ip -o link show 2>/dev/null | awk -F': ' '$2 !~ /lo|vir|docker/ {print $2}')

if [ ${#interfaces[@]} -eq 0 ]; then
    imprimir_error "No se encontró ninguna interfaz de red válida."
    pausar
    exit 1
elif [ ${#interfaces[@]} -eq 1 ]; then
    interfaz=${interfaces[0]}
    imprimir_info "Usando interfaz detectada automáticamente: $interfaz"
else
    echo -e "${YELLOW}Se detectaron múltiples interfaces. Seleccione una:${RESET}"
    select opcion in "${interfaces[@]}"; do
        if [[ -n "$opcion" ]]; then
            interfaz="$opcion"
            break
        else
            echo "❌ Opción no válida."
        fi
    done
fi

if [[ ! -r "/sys/class/net/$interfaz/address" ]]; then
    imprimir_error "No se pudo leer la dirección MAC de la interfaz $interfaz."
    pausar
    exit 1
fi

mac=$(cat "/sys/class/net/$interfaz/address" | tr '[:upper:]' '[:lower:]')

echo
echo -e "Interfaz: ${BOLD}$interfaz${RESET}"
echo -e "Dirección MAC: ${BOLD}${GREEN}$mac${RESET}"
echo -e "Archivo destino: ${CYAN}$ARCHIVO_MACS${RESET}"
echo

if grep -Fixq "$mac" "$ARCHIVO_MACS" 2>/dev/null; then
    imprimir_info "La MAC $mac ya se encuentra en el archivo de registro."
else
    echo "$mac" >> "$ARCHIVO_MACS"
    imprimir_exito "La MAC $mac fue registrada con éxito."
fi

echo
echo -e "${BOLD}MACs registradas en $ARCHIVO_MACS:${RESET}"
if [[ -s "$ARCHIVO_MACS" ]]; then
    nl -ba "$ARCHIVO_MACS"
else
    echo "  (Archivo vacío)"
fi

pausar