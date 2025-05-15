#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

while true; do
  clear
  echo -e "${BLUE}========== ASISTENTE POITE (Prof. Gabriel Vázquez) ==========${RESET}"
  echo -e "${CYAN}Bienvenido al asistente de administración de sistemas${RESET}"
  echo -e "${CYAN}Este asistente está diseñado para ayudar en la administración de sistemas${RESET}"
  echo -e "${CYAN}y facilitar tareas comunes de mantenimiento y configuración.${RESET}"
  echo -e "${BLUE}==============================================================${RESET}"
  echo -e "${MAGENTA}Por favor, seleccione una opción del menú:${RESET}"
  echo -e "${YELLOW}=====================================${RESET}"
  echo -e "${GREEN}1) 🌐 Red y conectividad${RESET}"
  echo -e "${GREEN}2) 👥 Usuarios y cuentas${RESET}"
  echo -e "${GREEN}3) 💻 Información del sistema${RESET}"
  echo -e "${GREEN}4) 🧹 Mantenimiento${RESET}"
  echo -e "${RED}0) Salir${RESET}"
  echo -e "${YELLOW}=====================================${RESET}"
  echo -ne "${BLUE}Seleccione una opción: ${RESET}"
  read opcion

  case $opcion in
    1) bash ./submenus/red.sh ;;
    2) bash ./submenus/usuarios.sh ;;
    3) bash ./submenus/sistema.sh ;;
    4) bash ./submenus/mantenimiento.sh ;;
    0) echo -e "${RED}Saliendo...${RESET}"; break ;;
    *) echo -e "${RED}Opción inválida. Presione Enter para continuar...${RESET}"; read ;;
  esac
done

echo -e "${GREEN}Gracias por usar el asistente. ¡Hasta luego!${RESET}"
