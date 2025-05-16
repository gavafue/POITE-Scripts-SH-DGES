#!/bin/bash

set -euo pipefail

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}⚠️ Este script debe ejecutarse como root (use sudo).${RESET}"
    exit 1
fi

# Verificar que APT esté disponible
if ! command -v apt >/dev/null 2>&1; then
    echo -e "${RED}❌ Este script solo es compatible con sistemas basados en Debian/Ubuntu.${RESET}"
    exit 1
fi

# Lista de paquetes a instalar
PAQUETES=(
    libreoffice
    pdfarranger
    gnome-dictionary
    firefox
    scratch
    thonny
    geany
    kate
    gcompris
    kalzium
    kstars
    marble
    kiwix-desktop
    gimp
    inkscape
    krita
    tuxpaint
    vlc
    audacity
    obs-studio
    shotcut
    kdenlive
    bleachbit
    timeshift
    synaptic
    gparted
    clamav
    clamtk
    gufw
    keepassxc
    onboard
    orca
    magnus
    librecad
    stellarium
    celestia
    tuxmath
    tuxtype
)

# Mostrar lista de paquetes y pedir confirmación
echo -e "${YELLOW}Se instalarán los siguientes paquetes:${RESET}"
for paquete in "${PAQUETES[@]}"; do
    echo "  - $paquete"
done
echo -e "${CYAN}¿Desea continuar con la instalación? (s/N)${RESET}"
read -r respuesta
if [[ ! "$respuesta" =~ ^[sS]$ ]]; then
    echo -e "${RED}Instalación cancelada por el usuario.${RESET}"
    exit 0
fi

# Actualizar repositorios
echo -e "${YELLOW}🔄 Actualizando repositorios...${RESET}"
apt update -y
apt upgrade -y

# Instalación masiva
echo -e "${CYAN}🚀 Instalando programas educativos...${RESET}"
for paquete in "${PAQUETES[@]}"; do
    echo -e "${CYAN}📦 Instalando: $paquete${RESET}"
    apt install -y "$paquete" || echo -e "${RED}❌ No se pudo instalar $paquete${RESET}"
done

# Fin
echo -e "${GREEN}🎉 Instalación completa de la suite educativa. Reinicie para aplicar algunos cambios si es necesario.${RESET}"
echo -e "${YELLOW}Presione ENTER para volver atrás...${RESET}"
read

# Fin del script
# Este script instala una serie de programas educativos en un sistema Linux basado en Debian/Ubuntu.
# Se asegura de que el script se ejecute con privilegios de superusuario.
# Primero verifica si APT está disponible y luego muestra una lista de los paquetes a instalar.
# Pide confirmación al usuario antes de proceder con la instalación.
# Luego actualiza los repositorios y procede a instalar cada paquete de la lista.
# Finalmente, informa al usuario que la instalación ha finalizado y le pide que presione ENTER para volver atrás.
# Se recomienda ejecutar este script con permisos de superusuario para un funcionamiento óptimo.