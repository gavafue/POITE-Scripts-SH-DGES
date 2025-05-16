#!/bin/bash

set -euo pipefail

ARCHIVO_MACS="./RegistrarIP/macs.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

pausa() {
  read -rp "Presione Enter para volver al menú..."
}

if [[ ! -d "./RegistrarIP" ]]; then
  echo -e "${RED}❌ El directorio './RegistrarIP' no existe.${RESET}"
  echo -e "${YELLOW}ℹ️  Asegúrate de que el script se está ejecutando desde el directorio correcto.${RESET}"
  pausa
  exit 1
fi

if [[ ! -f "$ARCHIVO_MACS" ]]; then
  echo -e "${RED}❌ El archivo '$ARCHIVO_MACS' no existe.${RESET}"
  echo -e "${YELLOW}ℹ️  Puedes crearlo con la función correspondiente.${RESET}"
  pausa
  exit 1
fi

if [[ ! -w "$ARCHIVO_MACS" ]]; then
  echo -e "${RED}❌ El archivo '$ARCHIVO_MACS' no tiene permisos de escritura.${RESET}"
  echo -e "${YELLOW}🔐 Solución: sudo chmod +w $ARCHIVO_MACS${RESET}"
  pausa
  exit 1
fi

> "$ARCHIVO_MACS"

if [[ $? -eq 0 ]]; then
  echo -e "${GREEN}✅ El archivo '$ARCHIVO_MACS' ha sido vaciado exitosamente.${RESET}"
else
  echo -e "${RED}❌ Ocurrió un error al intentar vaciar el archivo.${RESET}"
fi

pausa
# Fin del script
# Este script limpia el archivo de MACs registrado en el directorio ./RegistrarIP.
# Primero verifica si el directorio y el archivo existen.
# Luego, valida si el archivo es escribible.
# Si todo está en orden, vacía el archivo y confirma la operación.
# Se recomienda ejecutar este script con permisos de superusuario para un funcionamiento óptimo.
