#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador oficial de Visual Studio Code (Microsoft)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🧑‍💻 INSTALACIÓN DE VISUAL STUDIO CODE" "Instala el editor estándar para programación y talleres de informática"

if ! asegurar_root; then
    exit 1
fi

if command -v code >/dev/null 2>&1; then
    imprimir_info "Visual Studio Code ya se encuentra instalado en este equipo ($(code --version 2>/dev/null | head -n1))."
    pausar
    exit 0
fi

echo -e "${CYAN}1. Instalando herramientas necesarias (wget, gpg, apt-transport-https)...${RESET}"
sudo apt-get update -y
sudo apt-get install -y wget gpg apt-transport-https

echo
echo -e "${CYAN}2. Configurando clave GPG oficial en /etc/apt/keyrings/...${RESET}"
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --yes | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null

echo
echo -e "${CYAN}3. Agregando repositorio oficial de VS Code...${RESET}"
ARQ=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
echo "deb [arch=$ARQ signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

echo
echo -e "${CYAN}4. Instalando Visual Studio Code...${RESET}"
sudo apt-get update -y
sudo apt-get install -y code

if command -v code >/dev/null 2>&1; then
    imprimir_exito "Visual Studio Code instalado exitosamente. Puede ejecutarlo con el comando 'code' o desde el menú de aplicaciones."
else
    imprimir_error "Ocurrió un inconveniente durante la instalación de VS Code."
fi

pausar