#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Gestor de Proxy Institucional DGES para APT
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

APT_PROXY_FILE="/etc/apt/apt.conf.d/99proxy-dges.conf"
PROXY_PREDETERMINADO="10.4.142.24:8080"

imprimir_encabezado "🛡️ GESTOR DE PROXY INSTITUCIONAL DGES" "Configuración para descargas y actualizaciones APT en laboratorios"

echo -e "${BOLD}Estado actual del proxy en APT:${RESET}"
if [[ -f "$APT_PROXY_FILE" ]] && grep -q "Acquire::http::proxy" "$APT_PROXY_FILE" 2>/dev/null; then
    imprimir_exito "Proxy ACTIVO en $APT_PROXY_FILE:"
    cat "$APT_PROXY_FILE"
else
    imprimir_info "No hay proxy DGES configurado actualmente en APT (conexión directa)."
fi

echo
echo -e "  ${GREEN}1)${RESET} Activar / Cambiar Proxy DGES"
echo -e "  ${YELLOW}2)${RESET} Desactivar y eliminar Proxy DGES (Restaurar conexión directa)"
echo -e "  ${RED}0)${RESET} Cancelar y volver"
echo
echo -ne "${BOLD}Seleccione una acción [0-2]: ${RESET}"
read -r accion

case "$accion" in
    1)
        if ! asegurar_root; then
            exit 1
        fi
        echo
        echo -ne "${CYAN}Ingrese IP y puerto del proxy [Enter para usar $PROXY_PREDETERMINADO]: ${RESET}"
        read -r entrada_proxy
        PROXY_ELEGIDO="${entrada_proxy:-$PROXY_PREDETERMINADO}"

        echo -e "${CYAN}Configurando proxy con '$PROXY_ELEGIDO'...${RESET}"
        sudo tee "$APT_PROXY_FILE" > /dev/null <<EOF
Acquire::http::proxy "http://${PROXY_ELEGIDO}/";
Acquire::https::proxy "http://${PROXY_ELEGIDO}/";
EOF
        if [[ $? -eq 0 ]]; then
            imprimir_exito "Proxy DGES ($PROXY_ELEGIDO) configurado exitosamente para APT."
        else
            imprimir_error "Ocurrió un error al escribir en $APT_PROXY_FILE."
        fi
        ;;
    2)
        if ! asegurar_root; then
            exit 1
        fi
        echo -e "${YELLOW}Eliminando configuraciones de proxy...${RESET}"
        sudo rm -f "$APT_PROXY_FILE"
        sudo rm -f "/etc/apt/apt.conf.d/proxy.conf" 2>/dev/null || true
        imprimir_exito "Proxy eliminado. APT ahora se conectará directamente a Internet."
        ;;
    0)
        imprimir_info "Operación cancelada."
        ;;
    *)
        imprimir_error "Opción inválida."
        ;;
esac

pausar