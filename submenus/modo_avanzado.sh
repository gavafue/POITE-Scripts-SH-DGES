#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Modo Avanzado / SysAdmin & DevOps: Para administradores y técnicos experimentados
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

DIR_ANSIBLE="$BASE_DIR/ansible"
DIR_PLAYBOOKS="$DIR_ANSIBLE/playbooks"
INVENTARIO_INI="$DIR_DATOS/inventario_ansible.ini"

consola_adhoc_ansible() {
    imprimir_encabezado "🤖 CONSOLA AD-HOC DE ANSIBLE" "Prof. Gabriel Vázquez · Ejecución libre de comandos en el laboratorio"
    echo -e "Inventario activo: ${CYAN}$INVENTARIO_INI${RESET}"
    echo -e "Grupo predeterminado: ${GREEN}laboratorio${RESET} (o especifique un host particular)"
    echo
    echo -ne "Patrón de hosts [Enter para 'laboratorio']: "
    read -r patron_hosts
    local target="${patron_hosts:-laboratorio}"

    echo -ne "Ingrese el comando bash a ejecutar en todas las máquinas objetivo: "
    read -r cmd_ejecutar
    if [[ -z "$cmd_ejecutar" ]]; then
        imprimir_info "Operación cancelada."
        return 0
    fi

    echo
    echo -e "${YELLOW}Ejecutando: ansible $target -m command -a \"$cmd_ejecutar\"...${RESET}"
    echo "----------------------------------------------------------------------"
    ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible "$target" -i "$INVENTARIO_INI" -m command -a "$cmd_ejecutar"
    echo "----------------------------------------------------------------------"
    pausar
}

while true; do
    IP_LOCAL=$(obtener_ip_local)
    HOSTNAME_ACTUAL=$(hostname 2>/dev/null || echo "localhost")
    USUARIO_ACTUAL=$(whoami 2>/dev/null || echo "usuario")

    clear
    echo -e "${BLUE}======================================================================${RESET}"
    echo -e "${BOLD}${CYAN}   🖥️  ASISTENTE POITE · MODO AVANZADO / SYSADMIN & DEVOPS${RESET}"
    echo -e "   ${YELLOW}Prof. Gabriel Vázquez · Docente de Informática (INET / ANEP)${RESET}"
    echo -e "${BLUE}======================================================================${RESET}"
    echo -e "   ${BOLD}💻 Equipo:${RESET}  ${GREEN}${HOSTNAME_ACTUAL}${RESET}   |   ${BOLD}👤 Usuario:${RESET} ${MAGENTA}${USUARIO_ACTUAL}${RESET}"
    echo -e "   ${BOLD}🌐 IP:${RESET}      ${YELLOW}${IP_LOCAL}${RESET}      |   ${BOLD}🎯 Nivel:${RESET}   ${CYAN}Avanzado (SysAdmin)${RESET}"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -e "${BOLD}Herramientas de ingeniería y control de infraestructura:${RESET}"
    echo
    echo -e "  ${GREEN}1)${RESET}  🤖 Consola interactiva Ad-Hoc de Ansible (Ejecución libre en clúster)"
    echo -e "  ${GREEN}2)${RESET}  📋 Inspector y Editor de Inventario (${BOLD}inventario_ansible.ini${RESET})"
    echo -e "  ${GREEN}3)${RESET}  📂 Gestor directo de Playbooks YAML de producción"
    echo -e "  ${GREEN}4)${RESET}  🗺️  Mapeo de red con flags Nmap avanzados y análisis de secuencia"
    echo -e "  ${GREEN}5)${RESET}  🛡️  Inyección y depuración de Proxy DGES (/etc/environment, sudoers, DNF/APT)"
    echo -e "  ${GREEN}6)${RESET}  🧹 Sysprep Linux: sellado, vaciado de machine-id y regeneración firstboot"
    echo -e "  ${GREEN}7)${RESET}  💻 Auditoría profunda de hardware (lshw, lspci, smartctl, dmidecode)"
    echo -e "  ${GREEN}8)${RESET}  🌐 Servidor HTTP de aprovisionamiento SSH con socket de callbacks"
    echo -e "  ${GREEN}9)${RESET}  🔄 Replicación de laboratorio sin clonar discos (Perfil Maestro declarativo)"
    echo
    echo -e "  ${YELLOW}S)${RESET}  ⚙️  ${BOLD}Cambiar Nivel de Experiencia${RESET} (Básico / Intermedio / Avanzado)"
    echo -e "  ${RED}0)${RESET}  🚪 ${BOLD}Salir${RESET}"
    echo -e "${BLUE}======================================================================${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-9, S]: ${RESET}"
    read -r opt_avanzada

    case "$opt_avanzada" in
        1)
            consola_adhoc_ansible
            ;;
        2)
            if [[ -f "$INVENTARIO_INI" ]]; then
                "${EDITOR:-nano}" "$INVENTARIO_INI"
            else
                imprimir_aviso "El inventario aún no existe."
                pausar
            fi
            ;;
        3)
            bash "$BASE_DIR/Red/ejecutar_ansible_aula.sh"
            ;;
        4)
            bash "$BASE_DIR/Red/mapear_red_equipos.sh"
            ;;
        5)
            bash "$BASE_DIR/Red/proxy_DGES.sh"
            ;;
        6)
            bash "$BASE_DIR/ImagenMaestra/generalizar_para_clonar.sh"
            ;;
        7)
            bash "$BASE_DIR/Sistema/completo.sh"
            ;;
        8)
            bash "$BASE_DIR/Red/despliegue_ssh_aula.sh"
            ;;
        9)
            bash "$BASE_DIR/ReplicacionAula/menu_replicacion.sh"
            ;;
        [sS])
            seleccionar_nivel_poite_dialogo
            if [[ "$(obtener_nivel_poite)" != "3" ]]; then
                break
            fi
            ;;
        0)
            imprimir_exito "¡Hasta la próxima jornada educativa!"
            exit 0
            ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done
