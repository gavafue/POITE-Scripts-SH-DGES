#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador de WineHQ para ejecución de software educativo de Windows
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🍷 INSTALACIÓN DE WINEHQ" "Capa de compatibilidad para ejecutar programas educativos de Windows en Linux"

if ! asegurar_root; then
    exit 1
fi

if command -v wine >/dev/null 2>&1; then
    imprimir_info "Wine ya se encuentra instalado en este equipo ($(wine --version 2>/dev/null))."
    pausar
    exit 0
fi

echo -e "${CYAN}1. Habilitando soporte para arquitectura de 32 bits (i386)...${RESET}"
sudo dpkg --add-architecture i386

echo
echo -e "${CYAN}2. Instalando herramientas esenciales...${RESET}"
sudo apt-get update -y
sudo apt-get install -y wget gpg cabextract unzip software-properties-common

echo
echo -e "${CYAN}3. Descargando clave GPG de WineHQ...${RESET}"
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key 2>/dev/null || true

INFO_DISTRO=$(detectar_distro)
DISTRO_CODE=$(echo "$INFO_DISTRO" | cut -d'|' -f3)
DISTRO_CODE="${DISTRO_CODE:-focal}"

echo
echo -e "${CYAN}4. Agregando repositorio oficial de WineHQ para '$DISTRO_CODE'...${RESET}"
sudo wget -NP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/${DISTRO_CODE}/winehq-${DISTRO_CODE}.sources" 2>/dev/null || true

echo
echo -e "${CYAN}5. Instalando Wine...${RESET}"
sudo apt-get update -y
if ! sudo apt-get install -y --install-recommends winehq-stable 2>/dev/null; then
    imprimir_aviso "WineHQ oficial no disponible directamente para esta versión. Instalando Wine desde repositorios de la distribución..."
    sudo apt-get install -y wine wine32 wine64 winetricks
fi

if command -v wine >/dev/null 2>&1; then
    imprimir_exito "Wine instalado exitosamente ($(wine --version 2>/dev/null))."
else
    imprimir_error "No se pudo completar la instalación de Wine."
fi

pausar