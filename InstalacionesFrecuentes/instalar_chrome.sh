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

echo -e "${CYAN}🌐 Iniciando instalación de Google Chrome...${RESET}"

# Instalar wget si no está presente
if ! command -v wget >/dev/null 2>&1; then
  echo -e "${YELLOW}📦 Instalando wget...${RESET}"
  apt update && apt install -y wget
fi

# Descargar paquete .deb
echo -e "${CYAN}📥 Descargando instalador de Google Chrome...${RESET}"
wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Verificar descarga
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ No se pudo descargar Google Chrome. Abortando.${RESET}"
  exit 1
fi

# Instalar el paquete
echo -e "${CYAN}⚙️ Instalando Google Chrome...${RESET}"
apt install -y /tmp/google-chrome.deb

# Verificar instalación
if command -v google-chrome >/dev/null 2>&1; then
  echo -e "${GREEN}✅ Google Chrome instalado correctamente.${RESET}"
else
  echo -e "${RED}❌ La instalación falló.${RESET}"
fi
echo -e "${YELLOW}Presione ENTER para volver atrás...${RESET}"
read
#Fin del script
# Este script instala Google Chrome en un sistema Linux basado en Debian/Ubuntu.
# Se asegura de que el script se ejecute con privilegios de superusuario.
# Primero verifica si wget está instalado y lo instala si no lo está.
# Luego descarga el paquete .deb de Google Chrome y lo instala.
# Finalmente, verifica si la instalación fue exitosa.
# Se recomienda ejecutar este script con permisos de superusuario para un funcionamiento óptimo.