#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

while true; do
  clear
  echo -e "${BLUE}=========== 👥 Menú: Usuarios y Cuentas ===========${RESET}"
  echo -e "${MAGENTA}Seleccione una de las siguientes opciones:${RESET}"
  echo -e "${YELLOW}=========================================${RESET}"
  echo -e "${GREEN}1) ➕ Crear usuario liceo${RESET}"
  echo -e "${GREEN}2) 🔁 Cambiar usuario predeterminado${RESET}"
  echo -e "${GREEN}3) 🔐 Activar acceso SSH${RESET}"
  echo -e "${RED}0) 🔙 Volver al menú principal${RESET}"
  echo -e "${YELLOW}=========================================${RESET}"
  echo -ne "${BLUE}Seleccione una opción: ${RESET}"
  read opcion

  case $opcion in
    1) bash ../Usuarios/userliceo.sh ;;
    2) bash ../Usuarios/cambiar_usuario.sh ;;
    3) bash ../Usuarios/ssh.sh ;;
    0) break ;;
    *) echo -e "${RED}Opción inválida. Presione Enter para continuar...${RESET}"; read ;;
  esac
done

echo -e "${GREEN}Volviendo al menú principal...${RESET}"
