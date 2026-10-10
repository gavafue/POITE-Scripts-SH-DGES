#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Replicación de Laboratorio (Alternativa a Clonar Imágenes de Disco)
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "🚀 REPLICACIÓN DE LABORATORIO (SIN CLONAR DISCOS)" "Configure una PC Maestra y replique software y ajustes en PCs limpias por red"

    echo -e "  ${GREEN}1)${RESET}  📸 Capturar Perfil Maestro de esta computadora de referencia"
    echo -e "  ${GREEN}2)${RESET}  📋 Ver y auditar Perfil Maestro actual"
    echo -e "  ${GREEN}3)${RESET}  🚀 Desplegar Perfil Maestro en computadoras limpias del aula"
    echo -e "  ${GREEN}4)${RESET}  🧪 Probar despliegue en una sola computadora de prueba"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-4]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/ReplicacionAula/capturar_perfil_maestro.sh" ;;
        2) bash "$BASE_DIR/ReplicacionAula/ver_perfil_maestro.sh" ;;
        3) bash "$BASE_DIR/ReplicacionAula/desplegar_perfil_remoto.sh" ;;
        4)
            echo
            echo -ne "${CYAN}Ingrese la IP de la computadora de prueba: ${RESET}"
            read -r ip_test
            if [[ -n "$ip_test" ]]; then
                printf "2\n%s\n\n1\n\nS\n" "$ip_test" | bash "$BASE_DIR/ReplicacionAula/desplegar_perfil_remoto.sh"
            fi
            ;;
        0) break ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done
