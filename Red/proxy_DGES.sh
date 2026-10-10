#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Gestor Integral de Proxy Institucional DGES multi-distribución
# Configuración en todos los subsistemas: APT, DNF, /etc/environment,
# /etc/profile.d, /etc/wgetrc y preservación de variables en sudoers
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

APT_PROXY_FILE="/etc/apt/apt.conf.d/99proxy-dges.conf"
DNF_CONF_FILE="/etc/dnf/dnf.conf"
ENV_PROFILE_FILE="/etc/profile.d/proxy-dges.sh"
SYS_ENVIRONMENT_FILE="/etc/environment"
WGETRC_FILE="/etc/wgetrc"
SUDOERS_PROXY_FILE="/etc/sudoers.d/99-proxy-env"
PROXY_PREDETERMINADO="10.4.142.24:8080"

probar_conexion_proxy() {
    local proxy="$1"
    echo -e "${CYAN}Comprobando conectividad hacia Internet a través de '$proxy'...${RESET}"
    
    local url_test="https://uruguayeduca.anep.edu.uy"
    local url_backup="https://www.google.com"
    local exito=false

    if command -v curl >/dev/null 2>&1; then
        if curl -s -I --connect-timeout 5 --proxy "http://$proxy" "$url_test" >/dev/null 2>&1 || \
           curl -s -I --connect-timeout 5 --proxy "http://$proxy" "$url_backup" >/dev/null 2>&1; then
            exito=true
        fi
    elif command -v wget >/dev/null 2>&1; then
        if https_proxy="http://$proxy" http_proxy="http://$proxy" wget --spider --timeout=5 --tries=1 "$url_test" >/dev/null 2>&1 || \
           https_proxy="http://$proxy" http_proxy="http://$proxy" wget --spider --timeout=5 --tries=1 "$url_backup" >/dev/null 2>&1; then
            exito=true
        fi
    fi

    if [[ "$exito" = true ]]; then
        imprimir_exito "Conexión a Internet verificada con éxito a través del proxy ($proxy)."
        echo -e "  ${GREEN}✓ El gestor de paquetes ($PKG_MANAGER), terminales y navegadores tienen salida.${RESET}"
    else
        imprimir_aviso "No se recibió respuesta inmediata a través del proxy ($proxy)."
        echo -e "  ${YELLOW}Sugerencias para el aula:${RESET}"
        echo -e "  • Verifique que el cable de red esté conectado y tenga IP institucional."
        echo -e "  • En algunas salas la IP del proxy varía (verifique si corresponde a 10.4.142.24:8080 u otra IP del centro)."
    fi
}

imprimir_encabezado "🛡️ GESTOR INTEGRAL DE PROXY INSTITUCIONAL DGES" "Configuración global en el sistema ($DISTRO_FAMILY / $PKG_MANAGER)"

echo -e "${BOLD}Estado actual del proxy en los subsistemas del sistema:${RESET}"
proxy_detectado=false

if [[ -f "$APT_PROXY_FILE" ]] && grep -q "Acquire::http::proxy" "$APT_PROXY_FILE" 2>/dev/null; then
    proxy_val=$(grep -m1 "Acquire::http::proxy" "$APT_PROXY_FILE" | awk '{print $2}' | tr -d '";')
    echo -e "  ${GREEN}✓${RESET} APT ($APT_PROXY_FILE): ${CYAN}$proxy_val${RESET}"
    proxy_detectado=true
else
    echo -e "  ${GRAY}• APT: sin proxy configurado${RESET}"
fi

if [[ -f "$DNF_CONF_FILE" ]] && grep -q "^proxy=" "$DNF_CONF_FILE" 2>/dev/null; then
    proxy_val=$(grep -m1 "^proxy=" "$DNF_CONF_FILE" | cut -d'=' -f2)
    echo -e "  ${GREEN}✓${RESET} DNF ($DNF_CONF_FILE): ${CYAN}$proxy_val${RESET}"
    proxy_detectado=true
else
    echo -e "  ${GRAY}• DNF: sin proxy configurado${RESET}"
fi

if [[ -f "$SYS_ENVIRONMENT_FILE" ]] && grep -qi "http_proxy=" "$SYS_ENVIRONMENT_FILE" 2>/dev/null; then
    proxy_val=$(grep -im1 "^http_proxy=" "$SYS_ENVIRONMENT_FILE" | cut -d'=' -f2 | tr -d '"')
    echo -e "  ${GREEN}✓${RESET} Entorno global ($SYS_ENVIRONMENT_FILE): ${CYAN}$proxy_val${RESET}"
    proxy_detectado=true
else
    echo -e "  ${GRAY}• /etc/environment: sin proxy configurado${RESET}"
fi

if [[ -f "$ENV_PROFILE_FILE" ]]; then
    echo -e "  ${GREEN}✓${RESET} Terminales interactivas ($ENV_PROFILE_FILE): ${CYAN}ACTIVO${RESET}"
    proxy_detectado=true
else
    echo -e "  ${GRAY}• /etc/profile.d/proxy-dges.sh: no existe${RESET}"
fi

if [[ -f "$SUDOERS_PROXY_FILE" ]]; then
    echo -e "  ${GREEN}✓${RESET} Preservación en sudo ($SUDOERS_PROXY_FILE): ${CYAN}ACTIVO (env_keep)${RESET}"
else
    echo -e "  ${GRAY}• Sudoers (env_keep): inactivo${RESET}"
fi

if [[ -f "$WGETRC_FILE" ]] && grep -q "^http_proxy" "$WGETRC_FILE" 2>/dev/null; then
    echo -e "  ${GREEN}✓${RESET} Wget ($WGETRC_FILE): ${CYAN}ACTIVO${RESET}"
else
    echo -e "  ${GRAY}• Wget (/etc/wgetrc): sin proxy configurado${RESET}"
fi

echo
if [[ "$proxy_detectado" = false ]]; then
    imprimir_info "El sistema está configurado en conexión directa (sin proxy DGES)."
fi

echo
echo -e "  ${GREEN}1)${RESET} 🚀 Activar / Cambiar Proxy DGES en TODO el sistema (APT, DNF, variables y sudo)"
echo -e "  ${GREEN}2)${RESET} 🧪 Probar conectividad con Internet a través del proxy configurado"
echo -e "  ${YELLOW}3)${RESET} ❌ Desactivar y eliminar Proxy DGES (Restaurar conexión directa completa)"
echo -e "  ${RED}0)${RESET} 🔙 Cancelar y volver"
echo
echo -ne "${BOLD}Seleccione una acción [0-3]: ${RESET}"
read -r accion

case "$accion" in
    1)
        if ! asegurar_root; then
            exit 1
        fi
        echo
        echo -e "En salas de informática de DGES el proxy estándar es ${BOLD}${YELLOW}$PROXY_PREDETERMINADO${RESET}."
        echo -ne "${CYAN}Ingrese IP y puerto del proxy [Enter para usar $PROXY_PREDETERMINADO]: ${RESET}"
        read -r entrada_proxy
        PROXY_ELEGIDO="${entrada_proxy:-$PROXY_PREDETERMINADO}"
        # Limpiar protocolo si el usuario lo ingresó
        PROXY_ELEGIDO="${PROXY_ELEGIDO#http://}"
        PROXY_ELEGIDO="${PROXY_ELEGIDO#https://}"
        PROXY_ELEGIDO="${PROXY_ELEGIDO%/}"

        echo
        echo -e "${CYAN}Aplicando proxy DGES ($PROXY_ELEGIDO) en todos los niveles del sistema...${RESET}"

        # 1. Configurar APT si el directorio /etc/apt existe
        if [[ -d "/etc/apt" ]]; then
            sudo mkdir -p /etc/apt/apt.conf.d
            sudo tee "$APT_PROXY_FILE" > /dev/null <<EOF
Acquire::http::proxy "http://${PROXY_ELEGIDO}/";
Acquire::https::proxy "http://${PROXY_ELEGIDO}/";
EOF
            echo -e "  • [APT] Configurado en $APT_PROXY_FILE"
        fi

        # 2. Configurar DNF si existe dnf.conf
        if [[ -f "$DNF_CONF_FILE" ]]; then
            if grep -q "^proxy=" "$DNF_CONF_FILE"; then
                sudo sed -i "s|^proxy=.*|proxy=http://${PROXY_ELEGIDO}/|" "$DNF_CONF_FILE"
            else
                echo "proxy=http://${PROXY_ELEGIDO}/" | sudo tee -a "$DNF_CONF_FILE" > /dev/null
            fi
            echo -e "  • [DNF] Configurado en $DNF_CONF_FILE"
        fi

        # 3. Configurar /etc/environment (sin 'export', clave=valor nativo de PAM)
        if [[ -f "$SYS_ENVIRONMENT_FILE" ]]; then
            sudo sed -i '/^[hH][tT][tT][pP]_proxy=/d' "$SYS_ENVIRONMENT_FILE"
            sudo sed -i '/^[hH][tT][tT][pP][sS]_proxy=/d' "$SYS_ENVIRONMENT_FILE"
            sudo sed -i '/^[nN][oO]_proxy=/d' "$SYS_ENVIRONMENT_FILE"
        fi
        sudo tee -a "$SYS_ENVIRONMENT_FILE" > /dev/null <<EOF
http_proxy="http://${PROXY_ELEGIDO}/"
https_proxy="http://${PROXY_ELEGIDO}/"
HTTP_PROXY="http://${PROXY_ELEGIDO}/"
HTTPS_PROXY="http://${PROXY_ELEGIDO}/"
no_proxy="localhost,127.0.0.1,*.edu.uy,10.0.0.0/8"
NO_PROXY="localhost,127.0.0.1,*.edu.uy,10.0.0.0/8"
EOF
        echo -e "  • [Entorno del Sistema] Configurado en $SYS_ENVIRONMENT_FILE"

        # 4. Configurar /etc/profile.d/proxy-dges.sh (para bash y shells de login)
        sudo tee "$ENV_PROFILE_FILE" > /dev/null <<EOF
# Configuración Proxy DGES - Generado por Asistente POITE
export http_proxy="http://${PROXY_ELEGIDO}/"
export https_proxy="http://${PROXY_ELEGIDO}/"
export HTTP_PROXY="http://${PROXY_ELEGIDO}/"
export HTTPS_PROXY="http://${PROXY_ELEGIDO}/"
export no_proxy="localhost,127.0.0.1,*.edu.uy,10.0.0.0/8"
export NO_PROXY="localhost,127.0.0.1,*.edu.uy,10.0.0.0/8"
EOF
        sudo chmod 644 "$ENV_PROFILE_FILE"
        echo -e "  • [Shells Interactivas] Configurado en $ENV_PROFILE_FILE"

        # 5. Configurar /etc/sudoers.d/99-proxy-env (CRUCIAL para que sudo conserve variables de proxy)
        sudo mkdir -p /etc/sudoers.d
        sudo tee "$SUDOERS_PROXY_FILE" > /dev/null <<'EOF'
# Preservar variables de proxy al ejecutar sudo
Defaults env_keep += "http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY"
EOF
        sudo chmod 0440 "$SUDOERS_PROXY_FILE"
        if command -v visudo >/dev/null 2>&1; then
            if ! sudo visudo -c -f "$SUDOERS_PROXY_FILE" >/dev/null 2>&1; then
                sudo rm -f "$SUDOERS_PROXY_FILE"
                imprimir_aviso "Error de sintaxis en sudoers; archivo removido por seguridad."
            else
                echo -e "  • [Sudoers] Configurada preservación de proxy en $SUDOERS_PROXY_FILE"
            fi
        else
            echo -e "  • [Sudoers] Configurada preservación de proxy en $SUDOERS_PROXY_FILE"
        fi

        # 6. Configurar /etc/wgetrc si existe
        if [[ -f "$WGETRC_FILE" ]]; then
            sudo sed -i '/^http_proxy/d' "$WGETRC_FILE"
            sudo sed -i '/^https_proxy/d' "$WGETRC_FILE"
            sudo sed -i '/^use_proxy/d' "$WGETRC_FILE"
            sudo tee -a "$WGETRC_FILE" > /dev/null <<EOF
http_proxy = http://${PROXY_ELEGIDO}/
https_proxy = http://${PROXY_ELEGIDO}/
use_proxy = on
EOF
            echo -e "  • [Wget] Configurado en $WGETRC_FILE"
        fi

        # Exportar en la sesión de terminal actual
        export http_proxy="http://${PROXY_ELEGIDO}/"
        export https_proxy="http://${PROXY_ELEGIDO}/"
        export HTTP_PROXY="http://${PROXY_ELEGIDO}/"
        export HTTPS_PROXY="http://${PROXY_ELEGIDO}/"
        export no_proxy="localhost,127.0.0.1,*.edu.uy,10.0.0.0/8"
        export NO_PROXY="localhost,127.0.0.1,*.edu.uy,10.0.0.0/8"

        echo
        imprimir_exito "Proxy DGES ($PROXY_ELEGIDO) configurado con éxito en todo el sistema."
        echo
        probar_conexion_proxy "$PROXY_ELEGIDO"
        ;;

    2)
        echo
        # Buscar proxy activo
        detect_proxy=""
        if [[ -f "$APT_PROXY_FILE" ]]; then
            detect_proxy=$(grep -m1 "Acquire::http::proxy" "$APT_PROXY_FILE" 2>/dev/null | awk '{print $2}' | tr -d '";' | sed 's|http://||' | tr -d '/')
        fi
        if [[ -z "$detect_proxy" && -f "$SYS_ENVIRONMENT_FILE" ]]; then
            detect_proxy=$(grep -im1 "^http_proxy=" "$SYS_ENVIRONMENT_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"' | sed 's|http://||' | tr -d '/')
        fi
        detect_proxy="${detect_proxy:-$PROXY_PREDETERMINADO}"

        echo -ne "${CYAN}Ingrese IP:puerto del proxy a verificar [Enter para '$detect_proxy']: ${RESET}"
        read -r test_in
        probar_proxy="${test_in:-$detect_proxy}"
        probar_conexion_proxy "$probar_proxy"
        ;;

    3)
        if ! asegurar_root; then
            exit 1
        fi
        echo -e "${YELLOW}Eliminando configuraciones de proxy de todos los subsistemas...${RESET}"
        sudo rm -f "$APT_PROXY_FILE" 2>/dev/null || true
        sudo rm -f "/etc/apt/apt.conf.d/proxy.conf" 2>/dev/null || true
        if [[ -f "$DNF_CONF_FILE" ]]; then
            sudo sed -i '/^proxy=/d' "$DNF_CONF_FILE"
        fi
        sudo rm -f "$ENV_PROFILE_FILE" 2>/dev/null || true
        sudo rm -f "$SUDOERS_PROXY_FILE" 2>/dev/null || true

        if [[ -f "$SYS_ENVIRONMENT_FILE" ]]; then
            sudo sed -i '/^[hH][tT][tT][pP]_proxy=/d' "$SYS_ENVIRONMENT_FILE"
            sudo sed -i '/^[hH][tT][tT][pP][sS]_proxy=/d' "$SYS_ENVIRONMENT_FILE"
            sudo sed -i '/^[nN][oO]_proxy=/d' "$SYS_ENVIRONMENT_FILE"
        fi

        if [[ -f "$WGETRC_FILE" ]]; then
            sudo sed -i '/^http_proxy/d' "$WGETRC_FILE"
            sudo sed -i '/^https_proxy/d' "$WGETRC_FILE"
            sudo sed -i '/^use_proxy/d' "$WGETRC_FILE"
        fi

        unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY 2>/dev/null || true
        imprimir_exito "Proxy DGES eliminado por completo. El equipo ahora opera en conexión directa."
        ;;

    0)
        imprimir_info "Operación cancelada."
        ;;

    *)
        imprimir_error "Opción no válida."
        ;;
esac

pausar