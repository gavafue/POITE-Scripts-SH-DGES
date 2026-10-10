#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador de Google Chrome multi-distribución (Debian, Fedora, Arch, SUSE)
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

if [[ "$DISTRO_ARCH" != "x86_64" ]]; then
    imprimir_aviso "Google Chrome oficial solo provee binarios para arquitectura x86_64 (amd64). Tu arquitectura es $DISTRO_ARCH."
    imprimir_info "Se sugiere instalar Chromium en su lugar: 'sudo $PKG_MANAGER install chromium'."
    pausar
    exit 1
fi

echo -e "${CYAN}1. Verificando herramientas de descarga...${RESET}"
if ! command -v wget >/dev/null 2>&1 && ! command -v curl >/dev/null 2>&1; then
    instalar_paquetes wget
fi

case "$DISTRO_FAMILY" in
    debian)
        TEMP_PKG="/tmp/google-chrome-stable.deb"
        echo
        echo -e "${CYAN}2. Descargando paquete oficial .deb de Google Chrome...${RESET}"
        if wget -O "$TEMP_PKG" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"; then
            echo
            echo -e "${CYAN}3. Instalando paquete con APT y resolviendo dependencias...${RESET}"
            sudo apt-get install -y "$TEMP_PKG"
            rm -f "$TEMP_PKG"
        else
            imprimir_error "No se pudo descargar el instalador .deb de Google Chrome."
            pausar
            exit 1
        fi
        ;;
    redhat)
        TEMP_PKG="/tmp/google-chrome-stable.rpm"
        echo
        echo -e "${CYAN}2. Descargando paquete oficial .rpm de Google Chrome...${RESET}"
        if wget -O "$TEMP_PKG" "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"; then
            echo
            echo -e "${CYAN}3. Instalando paquete con $PKG_MANAGER...${RESET}"
            sudo "$PKG_MANAGER" install -y "$TEMP_PKG"
            rm -f "$TEMP_PKG"
        else
            imprimir_error "No se pudo descargar el instalador .rpm de Google Chrome."
            pausar
            exit 1
        fi
        ;;
    suse)
        TEMP_PKG="/tmp/google-chrome-stable.rpm"
        echo
        echo -e "${CYAN}2. Descargando paquete oficial .rpm de Google Chrome...${RESET}"
        if wget -O "$TEMP_PKG" "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"; then
            echo
            echo -e "${CYAN}3. Instalando paquete con Zypper...${RESET}"
            sudo zypper install -y "$TEMP_PKG"
            rm -f "$TEMP_PKG"
        else
            imprimir_error "No se pudo descargar el instalador de Google Chrome."
            pausar
            exit 1
        fi
        ;;
    arch)
        echo
        echo -e "${CYAN}2. Instalando Chromium en Arch Linux...${RESET}"
        instalar_paquetes chromium
        ;;
    *)
        imprimir_error "Distribución no soportada automáticamente para Google Chrome."
        pausar
        exit 1
        ;;
esac

if command -v google-chrome >/dev/null 2>&1 || command -v chromium >/dev/null 2>&1; then
    imprimir_exito "Navegador instalado correctamente. Disponible en el menú de aplicaciones del aula."
else
    imprimir_error "Falló la instalación del navegador."
fi

pausar