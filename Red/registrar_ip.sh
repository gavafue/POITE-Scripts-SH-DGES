#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Registrar IP del equipo actual en el archivo central de aula
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📝 REGISTRAR IP DEL EQUIPO ACTUAL" "Guarda la IP local en el registro central para distribución masiva"

ip_host=$(obtener_ip_local)

if [[ -z "$ip_host" || "$ip_host" == "127.0.0.1" ]]; then
    imprimir_error "No se pudo detectar una dirección IP de red válida."
    pausar
    exit 1
fi

echo -e "IP detectada: ${BOLD}${GREEN}$ip_host${RESET}"
echo -e "Archivo de destino: ${CYAN}$ARCHIVO_IPS${RESET}"
echo

if grep -Fxq "$ip_host" "$ARCHIVO_IPS" 2>/dev/null; then
    imprimir_info "La IP $ip_host ya se encontraba registrada previamente."
else
    echo "$ip_host" >> "$ARCHIVO_IPS"
    imprimir_exito "La IP $ip_host fue registrada correctamente."
fi

echo
echo -e "${BOLD}IPs registradas hasta el momento (${ARCHIVO_IPS}):${RESET}"
if [[ -s "$ARCHIVO_IPS" ]]; then
    nl -ba "$ARCHIVO_IPS"
else
    echo "  (Archivo vacío)"
fi

pausar