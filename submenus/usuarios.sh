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
  echo -e "${GREEN}1) ➕ Crear usuario ${RESET}"
  echo -e "${GREEN}2) 🔁 Cambiar usuario predeterminado${RESET}"
  echo -e "${GREEN}3) ➕ Crear usuarios por lotes${RESET}"
  echo -e "${GREEN}4) ➖ Eliminar usuario${RESET}"
  echo -e "${GREEN}5) 🔑 Resetear contraseña de usuario${RESET}"
  echo -e "${RED}0) 🔙 Volver al menú principal${RESET}"
  echo -e "${YELLOW}=========================================${RESET}"
  echo -ne "${BLUE}Seleccione una opción: ${RESET}"
  read opcion

  case $opcion in
    1) bash ./Usuarios/crear_usuario.sh ;;
    2) bash ./Usuarios/cambiar_usuario.sh ;;
    3) bash ./Usuarios/crear_usuarios_lote.sh ;;
    4) bash ./Usuarios/eliminar_usuario.sh ;;
    5) bash ./Usuarios/resetear_password.sh ;;
    0) break ;;
    *) echo -e "${RED}Opción inválida. Presione Enter para continuar...${RESET}"; read ;;
  esac
done

echo -e "${GREEN}Volviendo al menú principal...${RESET}"
