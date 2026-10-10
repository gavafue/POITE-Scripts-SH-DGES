#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES (Dirección General de Educación Secundaria)
# Herramienta de Administración y Mantenimiento de Laboratorios GNU/Linux
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

# Resolver ruta base canónica del script (soporta invocación vía symlink)
_FUENTE_CANONICA="${BASH_SOURCE[0]}"
while [[ -h "$_FUENTE_CANONICA" ]]; do
    _DIR_TEMP="$(cd -P "$(dirname "$_FUENTE_CANONICA")" && pwd)"
    _FUENTE_CANONICA="$(readlink "$_FUENTE_CANONICA")"
    [[ "$_FUENTE_CANONICA" != /* ]] && _FUENTE_CANONICA="$_DIR_TEMP/$_FUENTE_CANONICA"
done
BASE_DIR="$(cd -P "$(dirname "$_FUENTE_CANONICA")" && pwd)"
export BASE_DIR

# Cargar librería común
if [[ -f "$BASE_DIR/lib/comun.sh" ]]; then
    # shellcheck disable=SC1091
    source "$BASE_DIR/lib/comun.sh"
else
    echo "❌ Error crítico: No se encontró lib/comun.sh en $BASE_DIR" >&2
    exit 1
fi

# Trap para salida limpia con Ctrl+C
trap 'echo -e "\n${RED}Interrupción detectada. Saliendo...${RESET}"; exit 0' INT

# Bucle principal del menú
while true; do
    # Obtener métricas rápidas del sistema para el encabezado en vivo
    IP_LOCAL=$(obtener_ip_local)
    HOSTNAME_ACTUAL=$(hostname 2>/dev/null || echo "localhost")
    USUARIO_ACTUAL=$(whoami 2>/dev/null || echo "usuario")

    clear
    echo -e "${BLUE}======================================================================${RESET}"
    echo -e "${BOLD}${CYAN}   🖥️  ASISTENTE POITE · DGES / URUGUAY${RESET}"
    echo -e "   ${YELLOW}Prof. Gabriel Vázquez · Gestión de Laboratorios de Informática${RESET}"
    echo -e "${BLUE}======================================================================${RESET}"
    echo -e "   ${BOLD}💻 Equipo:${RESET}  ${GREEN}${HOSTNAME_ACTUAL}${RESET}   |   ${BOLD}👤 Usuario:${RESET} ${MAGENTA}${USUARIO_ACTUAL}${RESET}"
    echo -e "   ${BOLD}🌐 IP:${RESET}      ${YELLOW}${IP_LOCAL}${RESET}      |   ${BOLD}🐧 Sistema:${RESET} ${CYAN}${DISTRO_NAME} [${PKG_MANAGER}]${RESET}"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -e "${BOLD}${MAGENTA}Seleccione una categoría de administración:${RESET}"
    echo
    echo -e "  ${GREEN}1)${RESET} ${BOLD}🌐 Red y Conectividad${RESET}"
    echo -e "     ${CYAN}Mapeo lab1-pcXX, Proxy DGES, despliegue SSH, Ansible y control remoto${RESET}"
    echo
    echo -e "  ${GREEN}2)${RESET} ${BOLD}👥 Usuarios y Cuentas${RESET}"
    echo -e "     ${CYAN}Creación individual/lotes, autologin de aula, claves y permisos${RESET}"
    echo
    echo -e "  ${GREEN}3)${RESET} ${BOLD}🚀 Replicación de Laboratorio (Sin Clonar Discos)${RESET}"
    echo -e "     ${CYAN}Capturar PC Maestra y desplegar configuración completa a PCs limpias${RESET}"
    echo
    echo -e "  ${GREEN}4)${RESET} ${BOLD}🧹 Mantenimiento del Sistema${RESET}"
    echo -e "     ${CYAN}Reparación $PKG_MANAGER, repositorios, sincronización horaria y limpieza${RESET}"
    echo
    echo -e "  ${GREEN}5)${RESET} ${BOLD}🧩 Instalaciones Frecuentes${RESET}"
    echo -e "     ${CYAN}Visual Studio Code, navegadores web, Wine, Ansible y Suite Educativa${RESET}"
    echo
    echo -e "  ${GREEN}6)${RESET} ${BOLD}💻 Información del Sistema${RESET}"
    echo -e "     ${CYAN}Auditoría de hardware, CPU, memoria RAM, particiones y procesos${RESET}"
    echo
    echo -e "  ${GREEN}7)${RESET} ${BOLD}⚡ Diagnóstico Rápido del Puesto${RESET}"
    echo -e "     ${CYAN}Chequeo integral exprés de disco, red local, DNS y conectividad${RESET}"
    echo
    echo -e "  ${RED}0)${RESET} ${BOLD}🚪 Salir${RESET}"
    echo -e "${BLUE}======================================================================${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-7]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1)
            bash "$BASE_DIR/submenus/red.sh"
            ;;
        2)
            bash "$BASE_DIR/submenus/usuarios.sh"
            ;;
        3)
            bash "$BASE_DIR/ReplicacionAula/menu_replicacion.sh"
            ;;
        4)
            bash "$BASE_DIR/submenus/mantenimiento.sh"
            ;;
        5)
            bash "$BASE_DIR/submenus/instalaciones.sh"
            ;;
        6)
            bash "$BASE_DIR/submenus/sistema.sh"
            ;;
        7)
            bash "$BASE_DIR/Red/diagnostico_red.sh"
            ;;
        0)
            echo
            imprimir_exito "Gracias por utilizar el Asistente POITE. ¡Hasta la próxima jornada educativa!"
            exit 0
            ;;
        *)
            echo
            imprimir_error "Opción no válida. Por favor elija un número del 0 al 7."
            sleep 1.2
            ;;
    esac
done
