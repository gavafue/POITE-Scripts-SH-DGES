#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Preparación de Imagen Maestra (VirtualBox / Clonezilla)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "📦 PREPARACIÓN DE IMAGEN MAESTRA (VIRTUALBOX / CLONEZILLA)" "Configure su VM de referencia para distribuirla por red a todas las PCs del aula"

    echo -e "  ${GREEN}1)${RESET}  🚀 ${BOLD}Asistente Guiado Integral${RESET}: Acondicionar Imagen Maestra completa"
    echo -e "         ${CYAN}(Proxy + Alumno + Autologin + SSH + Clave Docente + Software + Reloj)${RESET}"
    echo
    echo -e "  ${GREEN}2)${RESET}  🛡️  Configurar Proxy Institucional DGES en la imagen"
    echo -e "  ${GREEN}3)${RESET}  👤 Configurar cuenta de estudiante ('alumno') y grupos multimedia"
    echo -e "  ${GREEN}4)${RESET}  🔁 Configurar inicio de sesión automático (Autologin)"
    echo -e "  ${GREEN}5)${RESET}  🔐 Instalar y habilitar Servidor SSH + Inyectar clave docente"
    echo -e "  ${GREEN}6)${RESET}  📚 Instalar Suite Educativa y software pedagógico (Chrome / VS Code)"
    echo -e "  ${GREEN}7)${RESET}  🕒 Sincronizar reloj y zona horaria (America/Montevideo)"
    echo
    echo -e "  ${YELLOW}8)${RESET}  🧹 ${BOLD}Sellar y Generalizar Sistema para Clonar (Sysprep Linux)${RESET}"
    echo -e "         ${YELLOW}(Vaciar machine-id, eliminar llaves SSH viejas, purgar cachés y apagar)${RESET}"
    echo
    echo -e "  ${GREEN}9)${RESET}  📖 Guía y Checklist para despliegue Multicast con Clonezilla"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-9]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/ImagenMaestra/preparar_imagen_maestra.sh" ;;
        2) bash "$BASE_DIR/Red/proxy_DGES.sh" ;;
        3) bash "$BASE_DIR/Usuarios/crear_usuario.sh" ;;
        4) bash "$BASE_DIR/Usuarios/cambiar_usuario.sh" ;;
        5) bash "$BASE_DIR/Mantenimiento/ssh.sh" ;;
        6) bash "$BASE_DIR/InstalacionesFrecuentes/suite_educativa.sh" ;;
        7) bash "$BASE_DIR/Mantenimiento/arreglar_reloj_ubuntu.sh" ;;
        8) bash "$BASE_DIR/ImagenMaestra/generalizar_para_clonar.sh" ;;
        9) bash "$BASE_DIR/ImagenMaestra/guia_clonezilla.sh" ;;
        0) break ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done
