#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador de WineHQ para software educativo de Windows multi-distribución
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

case "$DISTRO_FAMILY" in
    debian)
        echo -e "${CYAN}1. Habilitando soporte para arquitectura de 32 bits (i386)...${RESET}"
        sudo dpkg --add-architecture i386

        echo
        echo -e "${CYAN}2. Instalando herramientas esenciales...${RESET}"
        actualizar_repositorios
        instalar_paquetes wget gpg cabextract unzip software-properties-common

        echo
        echo -e "${CYAN}3. Descargando clave GPG de WineHQ...${RESET}"
        sudo mkdir -pm755 /etc/apt/keyrings
        sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key 2>/dev/null || true

        echo
        echo -e "${CYAN}4. Agregando repositorio oficial de WineHQ para '$DISTRO_CODENAME'...${RESET}"
        sudo wget -NP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/${DISTRO_CODENAME}/winehq-${DISTRO_CODENAME}.sources" 2>/dev/null || true

        echo
        echo -e "${CYAN}5. Instalando Wine...${RESET}"
        actualizar_repositorios
        if ! sudo apt-get install -y --install-recommends winehq-stable 2>/dev/null; then
            imprimir_aviso "WineHQ oficial no disponible directamente para esta versión. Instalando Wine desde repositorios de la distribución..."
            instalar_paquetes wine wine32 wine64 winetricks
        fi
        ;;

    redhat)
        echo -e "${CYAN}1. Instalando Wine y Winetricks desde repositorios oficiales de Fedora/RHEL...${RESET}"
        actualizar_repositorios
        instalar_paquetes wine winetricks
        ;;

    arch)
        echo -e "${CYAN}1. Instalando Wine y dependencias en Arch Linux...${RESET}"
        actualizar_repositorios
        instalar_paquetes wine winetricks wine-mono wine-gecko
        ;;

    suse)
        echo -e "${CYAN}1. Instalando Wine en openSUSE...${RESET}"
        actualizar_repositorios
        instalar_paquetes wine winetricks
        ;;

    *)
        imprimir_aviso "Intentando instalación genérica de wine..."
        instalar_paquetes wine winetricks
        ;;
esac

if command -v wine >/dev/null 2>&1; then
    imprimir_exito "Wine instalado exitosamente ($(wine --version 2>/dev/null))."
else
    imprimir_error "No se pudo completar la instalación de Wine."
fi

pausar