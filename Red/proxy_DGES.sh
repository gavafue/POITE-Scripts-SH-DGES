#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Gestor de Proxy Institucional DGES multi-distribución
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

APT_PROXY_FILE="/etc/apt/apt.conf.d/99proxy-dges.conf"
DNF_CONF_FILE="/etc/dnf/dnf.conf"
ENV_PROXY_FILE="/etc/profile.d/proxy-dges.sh"
PROXY_PREDETERMINADO="10.4.142.24:8080"

imprimir_encabezado "🛡️ GESTOR DE PROXY INSTITUCIONAL DGES" "Configuración para descargas y acceso a Internet en aulas ($DISTRO_FAMILY / $PKG_MANAGER)"

echo -e "${BOLD}Estado actual del proxy en el sistema:${RESET}"
proxy_detectado=false

if [[ -f "$APT_PROXY_FILE" ]] && grep -q "Acquire::http::proxy" "$APT_PROXY_FILE" 2>/dev/null; then
    imprimir_exito "Proxy ACTIVO en APT ($APT_PROXY_FILE):"
    cat "$APT_PROXY_FILE"
    proxy_detectado=true
fi

if [[ -f "$DNF_CONF_FILE" ]] && grep -q "^proxy=" "$DNF_CONF_FILE" 2>/dev/null; then
    imprimir_exito "Proxy ACTIVO en DNF ($DNF_CONF_FILE):"
    grep "^proxy=" "$DNF_CONF_FILE"
    proxy_detectado=true
fi

if [[ -f "$ENV_PROXY_FILE" ]]; then
    imprimir_exito "Proxy de entorno global ACTIVO ($ENV_PROXY_FILE)."
    proxy_detectado=true
fi

if [[ "$proxy_detectado" = false ]]; then
    imprimir_info "No hay proxy DGES configurado actualmente (conexión directa)."
fi

echo
echo -e "  ${GREEN}1)${RESET} Activar / Cambiar Proxy DGES (Gestor de paquetes + Variables de entorno)"
echo -e "  ${YELLOW}2)${RESET} Desactivar y eliminar Proxy DGES (Restaurar conexión directa completa)"
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

        # 1. Configurar APT si existe
        if [[ -d "/etc/apt" ]]; then
            sudo mkdir -p /etc/apt/apt.conf.d
            sudo tee "$APT_PROXY_FILE" > /dev/null <<EOF
Acquire::http::proxy "http://${PROXY_ELEGIDO}/";
Acquire::https::proxy "http://${PROXY_ELEGIDO}/";
EOF
            echo -e "  • Configurado proxy en APT ($APT_PROXY_FILE)"
        fi

        # 2. Configurar DNF si existe
        if [[ -f "$DNF_CONF_FILE" ]]; then
            if grep -q "^proxy=" "$DNF_CONF_FILE"; then
                sudo sed -i "s|^proxy=.*|proxy=http://${PROXY_ELEGIDO}/|" "$DNF_CONF_FILE"
            else
                echo "proxy=http://${PROXY_ELEGIDO}/" | sudo tee -a "$DNF_CONF_FILE" > /dev/null
            fi
            echo -e "  • Configurado proxy en DNF ($DNF_CONF_FILE)"
        fi

        # 3. Configurar variables de entorno del sistema (curl, wget, navegadores, terminales)
        sudo tee "$ENV_PROXY_FILE" > /dev/null <<EOF
export http_proxy="http://${PROXY_ELEGIDO}/"
export https_proxy="http://${PROXY_ELEGIDO}/"
export HTTP_PROXY="http://${PROXY_ELEGIDO}/"
export HTTPS_PROXY="http://${PROXY_ELEGIDO}/"
export no_proxy="localhost,127.0.0.1,*.edu.uy"
export NO_PROXY="localhost,127.0.0.1,*.edu.uy"
EOF
        sudo chmod +x "$ENV_PROXY_FILE"
        echo -e "  • Configurado proxy global del sistema ($ENV_PROXY_FILE)"

        imprimir_exito "Proxy DGES ($PROXY_ELEGIDO) aplicado correctamente."
        ;;
    2)
        if ! asegurar_root; then
            exit 1
        fi
        echo -e "${YELLOW}Eliminando configuraciones de proxy...${RESET}"
        sudo rm -f "$APT_PROXY_FILE" 2>/dev/null || true
        sudo rm -f "/etc/apt/apt.conf.d/proxy.conf" 2>/dev/null || true
        if [[ -f "$DNF_CONF_FILE" ]]; then
            sudo sed -i '/^proxy=/d' "$DNF_CONF_FILE"
        fi
        sudo rm -f "$ENV_PROXY_FILE" 2>/dev/null || true
        imprimir_exito "Proxy DGES eliminado. El equipo se conectará directamente a Internet."
        ;;
    0)
        imprimir_info "Operación cancelada."
        ;;
    *)
        imprimir_error "Opción inválida."
        ;;
esac

pausar