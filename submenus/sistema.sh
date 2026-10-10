#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Información del Sistema
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "💻 INFORMACIÓN DEL SISTEMA Y HARDWARE" "Auditoría de recursos, capacidades del equipo y sistema operativo"

    echo -e "  ${GREEN}1)${RESET}  📋 Auditoría consolidada completa (CPU, RAM, Discos, Kernel y Red)"
    echo -e "  ${GREEN}2)${RESET}  🏷️  Sistema operativo, entorno de escritorio y sesión (Wayland/X11)"
    echo -e "  ${GREEN}3)${RESET}  🧠 Procesador (CPU, modelo, arquitectura y frecuencias)"
    echo -e "  ${GREEN}4)${RESET}  🪫 Memoria RAM y Swap (Capacidad y porcentajes de uso)"
    echo -e "  ${GREEN}5)${RESET}  💽 Almacenamiento, discos y puntos de montaje"
    echo -e "  ${GREEN}6)${RESET}  🖧 Reporte completo de hardware (lshw)"
    echo -e "  ${GREEN}7)${RESET}  🧮 Monitor interactivo de procesos activos"
    echo -e "  ${GREEN}8)${RESET}  🧩 Versión del Kernel Linux"
    echo -e "  ${GREEN}9)${RESET}  📦 Variables de entorno del sistema"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-9]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/Sistema/completo.sh" ;;
        2) bash "$BASE_DIR/Sistema/so.sh" ;;
        3) bash "$BASE_DIR/Sistema/cpu.sh" ;;
        4) bash "$BASE_DIR/Sistema/memoria.sh" ;;
        5) bash "$BASE_DIR/Sistema/discos.sh" ;;
        6) bash "$BASE_DIR/Sistema/hardware.sh" ;;
        7) bash "$BASE_DIR/Sistema/procesos.sh" ;;
        8) bash "$BASE_DIR/Sistema/kernel.sh" ;;
        9) bash "$BASE_DIR/Sistema/variables.sh" ;;
        0) break ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done
