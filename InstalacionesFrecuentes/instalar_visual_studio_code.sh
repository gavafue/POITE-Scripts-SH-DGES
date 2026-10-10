#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador oficial de Visual Studio Code (Microsoft) multi-distribución
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

case "$DISTRO_FAMILY" in
    debian)
        echo -e "${CYAN}1. Instalando herramientas necesarias (wget, gpg, apt-transport-https)...${RESET}"
        actualizar_repositorios
        instalar_paquetes wget gpg apt-transport-https

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
        actualizar_repositorios
        instalar_paquetes code
        ;;

    redhat)
        echo -e "${CYAN}1. Importando clave GPG de Microsoft...${RESET}"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

        echo
        echo -e "${CYAN}2. Configurando repositorio de VS Code en /etc/yum.repos.d/...${RESET}"
        sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

        echo
        echo -e "${CYAN}3. Instalando Visual Studio Code con $PKG_MANAGER...${RESET}"
        actualizar_repositorios
        instalar_paquetes code
        ;;

    suse)
        echo -e "${CYAN}1. Importando clave GPG de Microsoft...${RESET}"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

        echo
        echo -e "${CYAN}2. Configurando repositorio en /etc/zypp/repos.d/...${RESET}"
        sudo tee /etc/zypp/repos.d/vscode.repo > /dev/null <<EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

        echo
        echo -e "${CYAN}3. Instalando con Zypper...${RESET}"
        actualizar_repositorios
        instalar_paquetes code
        ;;

    arch)
        echo -e "${CYAN}1. Instalando paquete oficial 'code' desde repositorios de Arch...${RESET}"
        instalar_paquetes code
        ;;

    *)
        imprimir_error "Distribución no soportada automáticamente para VS Code."
        pausar
        exit 1
        ;;
esac

if command -v code >/dev/null 2>&1; then
    imprimir_exito "Visual Studio Code instalado exitosamente. Puede ejecutarlo con el comando 'code' o desde el menú de aplicaciones."
else
    imprimir_error "Ocurrió un inconveniente durante la instalación de VS Code."
fi

pausar