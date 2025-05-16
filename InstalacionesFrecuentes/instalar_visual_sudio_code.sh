#!/bin/bash

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Verificar permisos de root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}⚠️ Este script debe ejecutarse como root (use sudo).${RESET}"
  exit 1
fi

echo -e "${CYAN}💻 Iniciando instalación de Visual Studio Code...${RESET}"

# Instalar dependencias
echo -e "${YELLOW}🔧 Instalando dependencias necesarias...${RESET}"
apt update
apt install -y wget gpg

# Descargar clave GPG
echo -e "${CYAN}🔑 Añadiendo clave GPG de Microsoft...${RESET}"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg

# Agregar repositorio de VS Code
echo -e "${CYAN}➕ Agregando repositorio de Visual Studio Code...${RESET}"
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

# Instalar VS Code
echo -e "${CYAN}📦 Instalando VS Code...${RESET}"
apt update
apt install -y code

# Verificar instalación
if command -v code >/dev/null 2>&1; then
  echo -e "${GREEN}✅ Visual Studio Code instalado correctamente.${RESET}"
else
  echo -e "${RED}❌ La instalación falló.${RESET}"
fi
echo -e "${YELLOW}Presione ENTER para volver atrás...${RESET}"
read
# Fin del script
# Este script instala Visual Studio Code en un sistema Linux basado en Debian/Ubuntu.
# Se asegura de que el script se ejecute con privilegios de superusuario.
# Primero instala las dependencias necesarias (wget y gpg).
# Luego descarga la clave GPG de Microsoft y agrega el repositorio de Visual Studio Code.
# Finalmente, instala Visual Studio Code y verifica si la instalación fue exitosa.