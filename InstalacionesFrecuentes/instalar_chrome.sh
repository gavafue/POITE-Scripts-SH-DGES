#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador de Google Chrome para sistemas basados en Debian / Ubuntu
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🌐 INSTALACIÓN DE GOOGLE CHROME" "Navegador web con soporte multimedia y compatibilidad con plataformas educativas"

if ! asegurar_root; then
    exit 1
fi

if command -v google-chrome >/dev/null 2>&1; then
    imprimir_info "Google Chrome ya se encuentra instalado en este equipo ($(google-chrome --version 2>/dev/null))."
    pausar
    exit 0
fi

ARQ=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
if [[ "$ARQ" != "amd64" ]]; then
    imprimir_aviso "Google Chrome oficial solo provee paquetes .deb para arquitectura amd64 (x86_64). Tu arquitectura es $ARQ."
    imprimir_info "Se sugiere instalar Chromium en su lugar: 'sudo apt install chromium-browser'."
    pausar
    exit 1
fi

echo -e "${CYAN}1. Instalando herramientas de descarga...${RESET}"
sudo apt-get update -y
sudo apt-get install -y wget

TEMP_DEB="/tmp/google-chrome-stable.deb"
echo
echo -e "${CYAN}2. Descargando paquete oficial de Google Chrome...${RESET}"
if wget -O "$TEMP_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"; then
    echo
    echo -e "${CYAN}3. Instalando paquete y resolviendo dependencias...${RESET}"
    sudo apt-get install -y "$TEMP_DEB"
    rm -f "$TEMP_DEB"

    if command -v google-chrome >/dev/null 2>&1; then
        imprimir_exito "Google Chrome instalado correctamente. Disponible en el menú de aplicaciones."
    else
        imprimir_error "Falló la instalación de Google Chrome."
    fi
else
    imprimir_error "No se pudo descargar el instalador de Google Chrome. Verifique la conexión a Internet."
fi

pausar