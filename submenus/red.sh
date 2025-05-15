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
  echo -e "${BLUE}========== 🌐 MENÚ: RED Y CONECTIVIDAD ==========${RESET}"
  echo -e "${CYAN}Gestione las opciones relacionadas con red y acceso a internet.${RESET}"
  echo -e "${YELLOW}===============================================${RESET}"
  echo -e "${GREEN}1) 📝 Registrar IP${RESET}"
  echo -e "${GREEN}2) 🛡️  Configurar proxy DGES${RESET}"
  echo -e "${GREEN}3) 🔄 Reiniciar red${RESET}"
  echo -e "${GREEN}4) 📦 Chequear repositorios (Ubuntu 20.04)${RESET}"
  echo -e "${GREEN}5) 📤 Distribuir script a equipos de red (SSH)${RESET}"
  echo -e "${GREEN}6) 🧹 Limpiar archivo de IP${RESET}"
  echo -e "${RED}0) 🔙 Volver al menú principal${RESET}"
  echo -e "${YELLOW}===============================================${RESET}"
  echo -ne "${MAGENTA}Seleccione una opción: ${RESET}"
  read opcion

  case $opcion in
    1) bash ./Red/registrar_ip.sh ;;
    2) bash ./Red/proxy_DGES.sh ;;
    3) bash ./Red/reiniciar_red.sh ;;
    4) bash ./Red/chequear_repositorios_ubuntu20-04.sh ;;
    5) bash ./Red/conexion_remota.sh ;;
    6) bash ./Red/limpiar_archivo_ip.sh ;;
    0) echo -e "${RED}Volviendo al menú principal...${RESET}"; break ;;
    *) echo -e "${RED}❌ Opción inválida. Presione Enter para continuar...${RESET}"; read ;;
  esac
done

# Mensaje de salida
echo -e "${GREEN}✅ Ha salido del menú de red y conectividad.${RESET}"
