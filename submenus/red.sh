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
  echo -e "${GREEN}5) 📤 Distribuir script a equipos de red (SSH) - IP${RESET}"
  echo -e "${GREEN}6) 🧹 Limpiar archivo de IP${RESET}"
  echo -e "${GREEN}7) 📝 Registrar MAC${RESET}"
  echo -e "${GREEN}8) 📤 Distribuir script a equipos de red (SSH) - MAC${RESET}"
  echo -e "${GREEN}9) 🧹 Limpiar archivo de MAC${RESET}"
  echo -e "${RED}0) 🔙 Volver al menú principal${RESET}"
  echo -e "${YELLOW}===============================================${RESET}"
  echo -ne "${MAGENTA}Seleccione una opción: ${RESET}"
  read opcion

  case $opcion in
    1) bash ./Red/registrar_ip.sh ;;
    2) bash ./Red/proxy_DGES.sh ;;
    3) bash ./Red/reiniciar_red.sh ;;
    4) bash ./Red/chequear_repositorios_ubuntu20-04.sh ;;
    5) bash ./Red/conexion_remota_ip.sh ;;
    6) bash ./Red/limpiar_archivo_ip.sh ;;
    7) bash ./Red/registrar_mac.sh ;;
    8) bash ./Red/conexion_remota_mac.sh ;;
    9) bash ./Red/limpiar_archivo_mac.sh ;;
    0) echo -e "${RED}Volviendo al menú principal...${RESET}"; break ;;
    *) echo -e "${RED}❌ Opción inválida. Presione Enter para continuar...${RESET}"; read ;;
  esac
done

# Mensaje de salida
echo -e "${GREEN}✅ Ha salido del menú de red y conectividad.${RESET}"

# Fin del script
# Este script presenta un menú interactivo para gestionar opciones relacionadas con red y conectividad.
# Permite registrar IPs, configurar proxy, reiniciar servicios de red, chequear repositorios y distribuir scripts a equipos de red.
# Se recomienda ejecutar este script con permisos de superusuario para un funcionamiento óptimo.
# Asegúrese de tener los permisos necesarios para realizar las acciones solicitadas.