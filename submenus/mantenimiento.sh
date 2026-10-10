#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Mantenimiento del Sistema
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "🧹 MANTENIMIENTO PREVENTIVO Y CORRECTIVO" "Tareas esenciales para optimizar y reparar equipos escolares"

    echo -e "  ${GREEN}1)${RESET}  🕒 Sincronizar reloj de sistema y hardware (Solución pila BIOS/SSL)"
    echo -e "  ${GREEN}2)${RESET}  🧱 Reparar dependencias APT y paquetes bloqueados (dpkg/apt)"
    echo -e "  ${GREEN}3)${RESET}  🧹 Limpieza profunda de almacenamiento (Cachés, logs y temporales)"
    echo -e "  ${GREEN}4)${RESET}  🔐 Instalar y activar servidor SSH (OpenSSH Server)"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-4]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/Mantenimiento/arreglar_reloj_ubuntu.sh" ;;
        2) bash "$BASE_DIR/Mantenimiento/reparar_dependencias.sh" ;;
        3) bash "$BASE_DIR/Mantenimiento/limpieza_disco.sh" ;;
        4) bash "$BASE_DIR/Mantenimiento/ssh.sh" ;;
        0) break ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done