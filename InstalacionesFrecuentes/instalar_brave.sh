#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador de Brave Browser multi-distribución
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🦁 INSTALACIÓN DE BRAVE BROWSER" "Navegador de alta velocidad con bloqueo nativo de publicidad para el aula"

if ! asegurar_root; then
    exit 1
fi

if command -v brave-browser >/dev/null 2>&1; then
    imprimir_info "Brave Browser ya se encuentra instalado ($(brave-browser --version 2>/dev/null))."
    pausar
    exit 0
fi

case "$DISTRO_FAMILY" in
    debian)
        echo -e "${CYAN}1. Instalando curl y dependencias de transporte...${RESET}"
        actualizar_repositorios
        instalar_paquetes curl apt-transport-https

        echo
        echo -e "${CYAN}2. Descargando clave GPG oficial de Brave...${RESET}"
        sudo mkdir -p /usr/share/keyrings
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

        echo
        echo -e "${CYAN}3. Registrando repositorio oficial APT...${RESET}"
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

        echo
        echo -e "${CYAN}4. Instalando Brave Browser...${RESET}"
        actualizar_repositorios
        instalar_paquetes brave-browser
        ;;

    redhat)
        echo -e "${CYAN}1. Importando clave GPG de Brave...${RESET}"
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

        echo
        echo -e "${CYAN}2. Configurando repositorio en /etc/yum.repos.d/...${RESET}"
        sudo curl -fsSLo /etc/yum.repos.d/brave-browser.repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

        echo
        echo -e "${CYAN}3. Instalando Brave Browser con $PKG_MANAGER...${RESET}"
        actualizar_repositorios
        instalar_paquetes brave-browser
        ;;

    suse)
        echo -e "${CYAN}1. Importando clave GPG de Brave...${RESET}"
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

        echo
        echo -e "${CYAN}2. Agregando repositorio con Zypper...${RESET}"
        sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo 2>/dev/null || true

        echo
        echo -e "${CYAN}3. Instalando con Zypper...${RESET}"
        actualizar_repositorios
        instalar_paquetes brave-browser
        ;;

    arch)
        if command -v flatpak >/dev/null 2>&1; then
            echo -e "${CYAN}1. Instalando Brave Browser vía Flatpak...${RESET}"
            flatpak install -y flathub com.brave.Browser
        else
            imprimir_aviso "En Arch Linux se sugiere instalar 'brave-bin' desde AUR o habilitar Flatpak."
            pausar
            exit 1
        fi
        ;;

    *)
        imprimir_error "Distribución no soportada automáticamente para Brave Browser."
        pausar
        exit 1
        ;;
esac

if command -v brave-browser >/dev/null 2>&1 || flatpak list 2>/dev/null | grep -q com.brave.Browser; then
    imprimir_exito "Brave Browser instalado correctamente. Ejecute 'brave-browser' o búscalo en el menú."
else
    imprimir_error "Ocurrió un error al instalar Brave Browser."
fi

pausar
