#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Usuarios y Cuentas
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "👥 GESTIÓN DE USUARIOS Y CUENTAS" "Administración de accesos para estudiantes, grupos y docentes"

    echo -e "  ${GREEN}1)${RESET}  ➕ Crear usuario individual (con control de sudo)"
    echo -e "  ${GREEN}2)${RESET}  📂 Crear usuarios en masa por archivo CSV"
    echo -e "  ${GREEN}3)${RESET}  🔁 Configurar inicio de sesión automático (Autologin LightDM/GDM3)"
    echo -e "  ${GREEN}4)${RESET}  🔑 Restablecer contraseña de usuario"
    echo -e "  ${GREEN}5)${RESET}  ➖ Eliminar cuenta de usuario"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-5]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/Usuarios/crear_usuario.sh" ;;
        2) bash "$BASE_DIR/Usuarios/crear_usuarios_lote.sh" ;;
        3) bash "$BASE_DIR/Usuarios/cambiar_usuario.sh" ;;
        4) bash "$BASE_DIR/Usuarios/resetear_password.sh" ;;
        5) bash "$BASE_DIR/Usuarios/eliminar_usuario.sh" ;;
        0) break ;;
        *)
            imprimir_error "Opción inválida."
            sleep 1
            ;;
    esac
done
