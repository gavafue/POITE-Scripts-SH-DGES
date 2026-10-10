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
    NIVEL_ACTUAL=$(obtener_nivel_poite)

    # Si el usuario tiene seleccionado Modo Básico (Nivel 1), redirigir
    if [[ "$NIVEL_ACTUAL" == "1" ]]; then
        bash "$BASE_DIR/submenus/modo_basico.sh"
        continue
    fi

    # Si el usuario tiene seleccionado Modo Avanzado (Nivel 3), redirigir
    if [[ "$NIVEL_ACTUAL" == "3" ]]; then
        bash "$BASE_DIR/submenus/modo_avanzado.sh"
        continue
    fi

    # --------------------------------------------------------------------------
    # NIVEL 2: MODO INTERMEDIO (ADMINISTRADOR DE AULA - FLUJO COMPLETO DGES)
    # --------------------------------------------------------------------------
    IP_LOCAL=$(obtener_ip_local)
    HOSTNAME_ACTUAL=$(hostname 2>/dev/null || echo "localhost")
    USUARIO_ACTUAL=$(whoami 2>/dev/null || echo "usuario")

    # Detección rápida de estado del proxy local
    if [[ -f "/etc/apt/apt.conf.d/99proxy-dges.conf" ]] || [[ -f "/etc/profile.d/proxy-dges.sh" ]] || grep -qi "http_proxy=" /etc/environment 2>/dev/null; then
        ESTADO_PROXY="${GREEN}ACTIVO${RESET}"
    else
        ESTADO_PROXY="${GRAY}Directo (Sin proxy)${RESET}"
    fi

    clear
    echo -e "${BLUE}======================================================================${RESET}"
    echo -e "${BOLD}${CYAN}   🖥️  ASISTENTE POITE · DGES / URUGUAY${RESET}"
    echo -e "   ${YELLOW}Prof. Gabriel Vázquez · Docente de Informática (INET / ANEP)${RESET}"
    echo -e "${BLUE}======================================================================${RESET}"
    echo -e "   ${BOLD}💻 Equipo:${RESET}  ${GREEN}${HOSTNAME_ACTUAL}${RESET}   |   ${BOLD}👤 Usuario:${RESET} ${MAGENTA}${USUARIO_ACTUAL}${RESET}"
    echo -e "   ${BOLD}🌐 IP:${RESET}      ${YELLOW}${IP_LOCAL}${RESET}      |   ${BOLD}🐧 Sistema:${RESET} ${CYAN}${DISTRO_NAME} [${PKG_MANAGER}]${RESET}"
    echo -e "   ${BOLD}🎯 Nivel:${RESET}   ${YELLOW}Intermedio (Admin Aula)${RESET}  [Presione '${BOLD}N${RESET}' para cambiar]"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -e "${BOLD}${MAGENTA}⚡ FLUJO DE INICIO DE AÑO Y CLONACIÓN (CLONEZILLA & ANSIBLE):${RESET}"
    echo
    echo -e "  ${GREEN}1)${RESET} ${BOLD}📦 Paso 1: Preparar Imagen Maestra en PC Personal${RESET} ${CYAN}(VirtualBox)${RESET}"
    echo -e "     ${GRAY}Internet directo sin proxy, alumno, autologin, software y sellado Sysprep${RESET}"
    echo
    echo -e "  ${GREEN}2)${RESET} ${BOLD}🚀 Paso 2: Post-Clonación Día 1 en el Liceo${RESET} ${CYAN}(Hostnames y Ansible)${RESET}"
    echo -e "     ${GRAY}Mapeo de aula, nombres lab1-pcXX y despliegue masivo de Proxy DGES${RESET}"
    echo
    echo -e "  ${GREEN}3)${RESET} ${BOLD}🛡️  Paso 3: Gestor de Proxy DGES Local${RESET} ${CYAN}(Habilitar/Verificar en este equipo)${RESET}"
    echo -e "     ${GRAY}APT, DNF, /etc/environment, sudoers y test de salida escolar${RESET}"
    echo
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -e "${BOLD}${MAGENTA}🛠️  ADMINISTRACIÓN Y GESTIÓN DIARIA DEL LABORATORIO:${RESET}"
    echo
    echo -e "  ${GREEN}4)${RESET} 🌐 Red y Conectividad (Diagnóstico, Mapeo, SSH y Control Remoto)"
    echo -e "  ${GREEN}5)${RESET} 👥 Usuarios y Cuentas (Alumno, Autologin, Cargas CSV y Claves)"
    echo -e "  ${GREEN}6)${RESET} 🧹 Mantenimiento del Sistema (Paquetes $PKG_MANAGER, Reloj BIOS, Limpieza)"
    echo -e "  ${GREEN}7)${RESET} 🧩 Instalaciones Frecuentes (VS Code, Chrome, Wine, Suite Educativa)"
    echo -e "  ${GREEN}8)${RESET} 🔄 Replicación Remota Alternativa (Configuración sin clonar discos)"
    echo -e "  ${GREEN}9)${RESET} 💻 Información del Sistema y Auditoría de Hardware"
    echo
    echo -e "  ${YELLOW}N)${RESET} 🎯 ${BOLD}Cambiar Nivel de Experiencia${RESET} (Básico / Intermedio / Avanzado)"
    echo -e "  ${RED}0)${RESET} 🚪 ${BOLD}Salir${RESET}"
    echo -e "${BLUE}======================================================================${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-9, N]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1)
            bash "$BASE_DIR/ImagenMaestra/menu_imagen_maestra.sh"
            ;;
        2)
            bash "$BASE_DIR/PostClonacion/menu_post_clonacion.sh"
            ;;
        3)
            bash "$BASE_DIR/Red/proxy_DGES.sh"
            ;;
        4)
            bash "$BASE_DIR/submenus/red.sh"
            ;;
        5)
            bash "$BASE_DIR/submenus/usuarios.sh"
            ;;
        6)
            bash "$BASE_DIR/submenus/mantenimiento.sh"
            ;;
        7)
            bash "$BASE_DIR/submenus/instalaciones.sh"
            ;;
        8)
            bash "$BASE_DIR/ReplicacionAula/menu_replicacion.sh"
            ;;
        9)
            bash "$BASE_DIR/submenus/sistema.sh"
            ;;
        [nN])
            seleccionar_nivel_poite_dialogo
            ;;
        0)
            echo
            imprimir_exito "Gracias por utilizar el Asistente POITE. ¡Hasta la próxima jornada educativa!"
            exit 0
            ;;
        *)
            echo
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done
