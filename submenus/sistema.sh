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

    echo -e "  ${GREEN}1)${RESET}  🧩 Información del Kernel"
    echo -e "  ${GREEN}2)${RESET}  🧠 Procesador (CPU, núcleos, arquitectura)"
    echo -e "  ${GREEN}3)${RESET}  🪫 Memoria RAM y Swap"
    echo -e "  ${GREEN}4)${RESET}  💽 Discos, particiones y almacenamiento"
    echo -e "  ${GREEN}5)${RESET}  🏷️  Sistema operativo y versión"
    echo -e "  ${GREEN}6)${RESET}  🧮 Procesos en ejecución"
    echo -e "  ${GREEN}7)${RESET}  📦 Variables de entorno"
    echo -e "  ${GREEN}8)${RESET}  🖧 Hardware detallado (lshw)"
    echo -e "  ${GREEN}9)${RESET}  📋 Auditoría completa consolidada"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-9]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/Sistema/kernel.sh" ;;
        2) bash "$BASE_DIR/Sistema/cpu.sh" ;;
        3) bash "$BASE_DIR/Sistema/memoria.sh" ;;
        4) bash "$BASE_DIR/Sistema/discos.sh" ;;
        5) bash "$BASE_DIR/Sistema/so.sh" ;;
        6) bash "$BASE_DIR/Sistema/procesos.sh" ;;
        7) bash "$BASE_DIR/Sistema/variables.sh" ;;
        8) bash "$BASE_DIR/Sistema/hardware.sh" ;;
        9) bash "$BASE_DIR/Sistema/completo.sh" ;;
        0) break ;;
        *)
            imprimir_error "Opción inválida."
            sleep 1
            ;;
    esac
done
