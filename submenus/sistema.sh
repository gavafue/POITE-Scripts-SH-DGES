#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

# Función para mostrar el menú
mostrar_menu_sistema() {
    clear
    echo -e "${BLUE}========== 💻 INFORMACIÓN DEL SISTEMA ==========${RESET}"
    echo -e "${CYAN}Revise los detalles del sistema operativo y el hardware.${RESET}"
    echo -e "${YELLOW}===============================================${RESET}"
    echo -e "${GREEN}1) 🧩 Información del kernel${RESET}"
    echo -e "${GREEN}2) 🧠 Información de la CPU${RESET}"
    echo -e "${GREEN}3) 🪫 Información de la memoria RAM${RESET}"
    echo -e "${GREEN}4) 💽 Información de los discos${RESET}"
    echo -e "${GREEN}5) 🏷️  Información del sistema operativo${RESET}"
    echo -e "${GREEN}6) 📦 Variables de entorno${RESET}"
    echo -e "${GREEN}7) 🧮 Procesos en ejecución${RESET}"
    echo -e "${GREEN}8) 🖧 Información de hardware (lshw)${RESET}"
    echo -e "${GREEN}9) 📋 Información completa del sistema${RESET}"
    echo -e "${RED}0) 🔙 Volver al menú principal${RESET}"
    echo -e "${YELLOW}===============================================${RESET}"
    echo -ne "${MAGENTA}Seleccione una opción: ${RESET}"
}

# Bucle principal
while true; do
    mostrar_menu_sistema
    read opcion
    
    case $opcion in
        1) bash ./Sistema/kernel.sh ;;
        2) bash ./Sistema/cpu.sh ;;
        3) bash ./Sistema/memoria.sh ;;
        4) bash ./Sistema/discos.sh ;;
        5) bash ./Sistema/so.sh ;;
        6) bash ./Sistema/variables.sh ;;
        7) bash ./Sistema/procesos.sh ;;
        8) bash ./Sistema/hardware.sh ;;
        9) bash ./Sistema/completo.sh ;;
        0) echo -e "${RED}Volviendo al menú principal...${RESET}"; break ;;
        *) 
            echo -e "${RED}❌ Opción inválida. Presione Enter para continuar...${RESET}"
            read
            ;;
    esac
done

# Mensaje de salida
echo -e "${GREEN}✅ Ha salido del menú de información del sistema.${RESET}"
