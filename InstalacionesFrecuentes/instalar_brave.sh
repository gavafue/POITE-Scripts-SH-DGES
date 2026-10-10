#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador de Brave Browser (Privacidad y bajo consumo)
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

echo -e "${CYAN}1. Instalando curl y dependencias de transporte...${RESET}"
sudo apt-get update -y
sudo apt-get install -y curl apt-transport-https

echo
echo -e "${CYAN}2. Descargando clave GPG oficial de Brave...${RESET}"
sudo mkdir -p /usr/share/keyrings
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo
echo -e "${CYAN}3. Registrando repositorio oficial APT (línea única)...${RESET}"
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

echo
echo -e "${CYAN}4. Instalando Brave Browser...${RESET}"
sudo apt-get update -y
sudo apt-get install -y brave-browser

if command -v brave-browser >/dev/null 2>&1; then
    imprimir_exito "Brave Browser instalado correctamente. Ejecute 'brave-browser' o búscalo en el menú."
else
    imprimir_error "Ocurrió un error al instalar Brave Browser."
fi

pausar
