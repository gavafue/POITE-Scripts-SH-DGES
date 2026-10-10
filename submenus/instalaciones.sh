#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Instalaciones Frecuentes
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "🧩 INSTALACIONES FRECUENTES Y PAQUETES DE AULA" "Instalación guiada de software pedagógico y herramientas de desarrollo"

    echo -e "  ${GREEN}1)${RESET}  🧑‍💻 Visual Studio Code (Editor de código oficial)"
    echo -e "  ${GREEN}2)${RESET}  🌐 Google Chrome (Navegador estándar con soporte multimedia)"
    echo -e "  ${GREEN}3)${RESET}  🦁 Brave Browser (Navegador rápido con bloqueo de anuncios)"
    echo -e "  ${GREEN}4)${RESET}  🍷 WineHQ (Capa de compatibilidad para software Windows)"
    echo -e "  ${GREEN}5)${RESET}  📚 Suite de Software Educativo (Por áreas o completa)"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-5]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/InstalacionesFrecuentes/instalar_visual_studio_code.sh" ;;
        2) bash "$BASE_DIR/InstalacionesFrecuentes/instalar_chrome.sh" ;;
        3) bash "$BASE_DIR/InstalacionesFrecuentes/instalar_brave.sh" ;;
        4) bash "$BASE_DIR/InstalacionesFrecuentes/instalar_wine.sh" ;;
        5) bash "$BASE_DIR/InstalacionesFrecuentes/suite_educativa.sh" ;;
        0) break ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done
