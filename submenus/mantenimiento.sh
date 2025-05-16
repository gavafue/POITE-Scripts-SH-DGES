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
  echo -e "${BLUE}========== 🧹 MENÚ DE MANTENIMIENTO ==========${RESET}"
  echo -e "${CYAN}Seleccione una acción para realizar tareas de mantenimiento.${RESET}"
  echo -e "${YELLOW}==============================================${RESET}"
  echo -e "${GREEN}1) 🕒 Arreglar reloj de Ubuntu (sincronizar con NTP)${RESET}"
  echo -e "${CYAN}   (Especialmente pensado para equipos con poca batería en la pila de la BIOS.${RESET}"
  echo -e "${CYAN}    Crea un proceso que sincroniza la hora con Internet cada vez que la máquina enciende,${RESET}"
  echo -e "${CYAN}    para evitar problemas de navegación.)${RESET}"
  echo -e "${GREEN}2) 🧱 Reparar dependencias y actualizar el sistema${RESET}"
  echo -e "${CYAN}   - Chequea dependencias fallidas (apt-get check)${RESET}"
  echo -e "${CYAN}   - Configura paquetes pendientes (dpkg --configure -a)${RESET}"
  echo -e "${CYAN}   - Repara instalaciones rotas (apt-get install -f)${RESET}"
  echo -e "${CYAN}   - Busca e instala todas las actualizaciones necesarias (apt-get update && apt-get upgrade)${RESET}"
  echo -e "${GREEN}3) 🔐 Instalar servicio SSH (OpenSSH Server)${RESET}"
  echo -e "${CYAN}   - Instala y habilita el servicio SSH para acceso remoto seguro.${RESET}"
  echo -e "${RED}0) 🔙 Volver al menú principal${RESET}"
  echo -e "${YELLOW}==============================================${RESET}"
  echo -ne "${MAGENTA}Seleccione una opción: ${RESET}"
  read opcion

  case $opcion in
    1) bash ./Mantenimiento/arreglar_reloj_ubuntu.sh ;;
    2) bash ./Mantenimiento/reparar_dependencias.sh ;;
    3) bash ./Mantenimiento/ssh.sh ;;
    0) echo -e "${RED}Volviendo al menú principal...${RESET}"; break ;;
    *) echo -e "${RED}❌ Opción inválida. Presione Enter para continuar...${RESET}"; read ;;
  esac
done

# Fin del script
# Este script es parte de un menú de mantenimiento para Ubuntu.
# Permite realizar tareas de mantenimiento como arreglar el reloj, reparar dependencias e instalar SSH.
# Se utiliza para facilitar la administración del sistema y asegurar su correcto funcionamiento.
# El script utiliza colores para mejorar la legibilidad y la experiencia del usuario.
# Se recomienda ejecutarlo con privilegios de superusuario para evitar problemas de permisos.
# Asegúrate de tener los permisos necesarios para ejecutar los scripts de mantenimiento.