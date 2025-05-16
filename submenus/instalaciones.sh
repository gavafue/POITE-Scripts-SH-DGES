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
  echo -e "${BLUE}========== 🧩 MENÚ DE INSTALACIONES ==========${RESET}"
  echo -e "${CYAN}Seleccione una opción para instalar aplicaciones comunes.${RESET}"
  echo -e "${YELLOW}==============================================${RESET}"
  echo -e "${GREEN}1) 🦁 Instalar Navegador Brave${RESET}"
  echo -e "${GREEN}2) 🧑‍💻 Instalar Visual Studio Code${RESET}"
  echo -e "${GREEN}3) 🌐 Instalar Navegador Chrome${RESET}"
  echo -e "${GREEN}4) 📚 Instalar Suite Educativa${RESET}"
  echo -e "${CYAN}     - Esta opción instalará: libreoffice, pdfarranger, gnome-dictionary, firefox, scratch, thonny, geany, kate, gcompris, kalzium, kstars, marble, kiwix-desktop, gimp, inkscape, krita, tuxpaint, vlc, audacity, obs-studio, shotcut, kdenlive, bleachbit, timeshift, synaptic, gparted, clamav, clamtk, gufw, keepassxc, onboard, orca, magnus, librecad, stellarium, celestia, tuxmath, tuxtype.${RESET}"
  echo -e "${RED}0) 🔙 Volver al menú principal${RESET}"
  echo -e "${YELLOW}==============================================${RESET}"
  echo -ne "${MAGENTA}Seleccione una opción: ${RESET}"
  read opcion

  case $opcion in
    1) bash ./InstalacionesFrecuentes/instalar_brave.sh ;;
    2) bash ./InstalacionesFrecuentes/instalar_visual_studio_code.sh ;;
    3) bash ./InstalacionesFrecuentes/instalar_chrome.sh ;;
    4) bash ./InstalacionesFrecuentes/suite_educativa.sh ;;
    0) 
      echo -e "${RED}↩️  Volviendo al menú principal...${RESET}" 
      sleep 1
      break 
      ;;
    *) 
      echo -e "${RED}❌ Opción inválida. Presione Enter para continuar...${RESET}"
      read
      ;;
  esac
done
