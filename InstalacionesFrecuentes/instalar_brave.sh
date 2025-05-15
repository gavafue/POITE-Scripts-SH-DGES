#!/bin/bash

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Verificar permisos
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}⚠️ Este script debe ejecutarse como root (use sudo).${RESET}"
  exit 1
fi

echo -e "${CYAN}🚀 Iniciando instalación del navegador Brave...${RESET}"

# Paso 1: Instalar curl si no está presente
echo -e "${YELLOW}🔍 Verificando si 'curl' está instalado...${RESET}"
if ! command -v curl >/dev/null 2>&1; then
  echo -e "${YELLOW}📦 Instalando curl...${RESET}"
  apt update && apt install -y curl
else
  echo -e "${GREEN}✅ 'curl' ya está instalado.${RESET}"
fi

# Paso 2: Descargar clave GPG
echo -e "${CYAN}🔑 Descargando clave GPG del repositorio de Brave...${RESET}"
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
  https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Error al descargar la clave GPG. Abortando.${RESET}"
  exit 1
fi

# Paso 3: Agregar repositorio a sources.list.d
echo -e "${CYAN}➕ Agregando repositorio de Brave a APT...${RESET}"
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
https://brave-browser-apt-release.s3.brave.com/ stable main" \
> /etc/apt/sources.list.d/brave-browser-release.list

# Paso 4: Actualizar APT
echo -e "${YELLOW}🔄 Actualizando listas de paquetes...${RESET}"
apt update

# Paso 5: Instalar Brave
echo -e "${CYAN}📦 Instalando Brave Browser...${RESET}"
apt install -y brave-browser

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Brave se ha instalado correctamente.${RESET}"
else
  echo -e "${RED}❌ Hubo un problema durante la instalación de Brave.${RESET}"
  exit 1
fi

# Fin
echo -e "${GREEN}🎉 ¡Instalación completa! Puede abrir Brave desde el menú o ejecutando 'brave-browser'.${RESET}"
