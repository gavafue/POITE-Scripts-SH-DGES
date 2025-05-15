#!/bin/bash

set -euo pipefail

# Archivo donde se registran las IPs
ARCHIVO_IPS="./RegistrarIP/ips.txt"

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Validar si existe el directorio
if [[ ! -d "./RegistrarIP" ]]; then
  echo -e "${RED}❌ El directorio './RegistrarIP' no existe.${RESET}"
  echo -e "${YELLOW}ℹ️  Asegúrate de que el script se está ejecutando desde el directorio correcto.${RESET}"
  read -p "Presione Enter para volver al menú..."
  exit 1
fi

# Validar si existe el archivo
if [[ ! -f "$ARCHIVO_IPS" ]]; then
  echo -e "${RED}❌ El archivo '$ARCHIVO_IPS' no existe.${RESET}"
  echo -e "${YELLOW}ℹ️  Puedes crearlo con la función Registrar IP${RESET}"
  read -p "Presione Enter para volver al menú..."
  exit 1
fi

# Validar si el archivo es escribible
if [[ ! -w "$ARCHIVO_IPS" ]]; then
  echo -e "${RED}❌ El archivo '$ARCHIVO_IPS' no tiene permisos de escritura.${RESET}"
  echo -e "${YELLOW}🔐 Solución: sudo chmod +w $ARCHIVO_IPS${RESET}"
  read -p "Presione Enter para volver al menú..."
  exit 1
fi

# Vaciar el archivo
> "$ARCHIVO_IPS"

# Confirmar operación
if [[ $? -eq 0 ]]; then
  echo -e "${GREEN}✅ El archivo '$ARCHIVO_IPS' ha sido vaciado exitosamente.${RESET}"
else
  echo -e "${RED}❌ Ocurrió un error al intentar vaciar el archivo.${RESET}"
fi

# Pausa final
read -p "Presione Enter para volver al menú..."
