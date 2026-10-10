#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Mantenimiento del Sistema
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "🧹 MANTENIMIENTO PREVENTIVO Y CORRECTIVO" "Tareas esenciales para optimizar y reparar equipos escolares ($DISTRO_FAMILY)"

    echo -e "  ${GREEN}1)${RESET}  🕒 Sincronizar reloj de sistema y hardware (Solución pila BIOS/SSL)"
    echo -e "  ${GREEN}2)${RESET}  🧱 Reparar dependencias y paquetes bloqueados ($PKG_MANAGER)"
    echo -e "  ${GREEN}3)${RESET}  📦 Verificar integridad de repositorios oficiales ($PKG_MANAGER)"
    echo -e "  ${GREEN}4)${RESET}  🧹 Limpieza profunda de almacenamiento ($PKG_MANAGER, cachés y logs)"
    echo -e "  ${GREEN}5)${RESET}  🔐 Servidor SSH: instalar, activar o verificar estado local"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-5]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/Mantenimiento/arreglar_reloj_ubuntu.sh" ;;
        2) bash "$BASE_DIR/Mantenimiento/reparar_dependencias.sh" ;;
        3) bash "$BASE_DIR/Mantenimiento/chequear_repositorios.sh" ;;
        4) bash "$BASE_DIR/Mantenimiento/limpieza_disco.sh" ;;
        5) bash "$BASE_DIR/Mantenimiento/ssh.sh" ;;
        0) break ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done