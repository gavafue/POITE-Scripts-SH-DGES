#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Post-Clonación Día 1 - Asignación de Hostnames y Orquestación Ansible
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

DIR_ANSIBLE="$BASE_DIR/ansible"
DIR_PLAYBOOKS="$DIR_ANSIBLE/playbooks"
INVENTARIO_INI="$DIR_DATOS/inventario_ansible.ini"

ejecutar_playbook() {
    local pb="$1"
    local extra_args="${2:-}"

    if ! command -v ansible >/dev/null 2>&1; then
        imprimir_aviso "Ansible no se encuentra instalado en este equipo."
        echo -ne "¿Desea instalar Ansible ahora? (S/n): "
        read -r resp_inst
        if [[ -z "$resp_inst" || "$resp_inst" =~ ^[sS]$ ]]; then
            bash "$BASE_DIR/InstalacionesFrecuentes/instalar_ansible.sh"
        else
            return 1
        fi
    fi

    if [[ ! -f "$INVENTARIO_INI" ]]; then
        imprimir_error "No se encontró el inventario de Ansible en $INVENTARIO_INI."
        return 1
    fi

    echo
    echo -e "${CYAN}Ejecutando: $pb en todas las PCs del laboratorio...${RESET}"
    echo "----------------------------------------------------------------------"
    if [[ -n "$extra_args" ]]; then
        ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/$pb" -e "$extra_args"
    else
        ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/$pb"
    fi
    echo "----------------------------------------------------------------------"
    pausar
}

while true; do
    imprimir_encabezado "🚀 POST-CLONACIÓN DÍA 1: ASIGNACIÓN Y CONTROL CON ANSIBLE" "Tareas iniciales tras encender las PCs clonadas con Clonezilla"

    echo -e "  ${GREEN}1)${RESET}  🗺️  ${BOLD}Mapear red y detectar equipos clonados en el aula${RESET}"
    echo -e "         ${CYAN}(Descubre las direcciones IP de todas las computadoras recién encendidas)${RESET}"
    echo
    echo -e "  ${GREEN}2)${RESET}  🏷️  ${BOLD}Asignación masiva secuencial de Hostnames (lab1-pcXX)${RESET}"
    echo -e "         ${CYAN}(Asigna nombres tipo lab1-pc01... lab1-pc30 vía SSH y genera el inventario)${RESET}"
    echo
    echo -e "  ${GREEN}3)${RESET}  📋 Ver / Editar inventario de Ansible del aula"
    echo -e "  ${GREEN}4)${RESET}  📡 Probar conectividad con todo el aula (Ping masivo con Ansible)"
    echo -e "  ${GREEN}5)${RESET}  🕒 Sincronizar reloj y zona horaria (Montevideo) en todo el aula"
    echo -e "  ${GREEN}6)${RESET}  🛡️  Verificar salida a Internet y Proxy DGES en todas las PCs"
    echo -e "  ${GREEN}7)${RESET}  📢 Emitir mensaje o notificación a las terminales de los estudiantes"
    echo -e "  ${YELLOW}8)${RESET}  🔌 Control de energía masivo (Apagar o reiniciar todo el aula)"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-8]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1)
            bash "$BASE_DIR/Red/mapear_red_equipos.sh"
            ;;
        2)
            # Ejecuta el modo 3 de asignación en lote
            bash "$BASE_DIR/Red/asignar_hostname.sh" <<< "3"
            ;;
        3)
            echo
            if [[ -f "$INVENTARIO_INI" ]]; then
                echo -e "${BOLD}Inventario actual de Ansible ($INVENTARIO_INI):${RESET}"
                echo "----------------------------------------------------------------------"
                cat "$INVENTARIO_INI"
                echo "----------------------------------------------------------------------"
                echo
                echo -ne "¿Desea editar este archivo manualmente con nano? (s/N): "
                read -r resp_edit
                if [[ "$resp_edit" =~ ^[sS]$ ]]; then
                    "${EDITOR:-nano}" "$INVENTARIO_INI"
                fi
            else
                imprimir_aviso "El archivo de inventario aún no existe. Ejecute el Mapeo y Asignación de Hostnames."
                pausar
            fi
            ;;
        4)
            ejecutar_playbook "01_ping_aula.yml"
            ;;
        5)
            ejecutar_playbook "02_sincronizar_reloj.yml"
            ;;
        6)
            ejecutar_playbook "06_verificar_proxy_internet.yml"
            ;;
        7)
            echo
            echo -ne "${CYAN}Ingrese el mensaje a transmitir a las terminales del aula: ${RESET}"
            read -r texto_msg
            if [[ -n "$texto_msg" ]]; then
                ejecutar_playbook "08_notificar_alumnos.yml" "mensaje=$texto_msg"
            fi
            ;;
        8)
            echo
            echo -e "${YELLOW}Control de energía en bloque para el aula:${RESET}"
            echo -e "  [1] Apagar todas las PCs del aula (Final de turno)"
            echo -e "  [2] Reiniciar todas las PCs del aula"
            echo -e "  [0] Cancelar"
            echo -ne "${BOLD}Seleccione una opción [0-2]: ${RESET}"
            read -r opt_pwr
            case "$opt_pwr" in
                1)
                    echo -ne "${RED}¿Confirma el apagado inmediato de todo el laboratorio? (s/N): ${RESET}"
                    read -r conf_off
                    if [[ "$conf_off" =~ ^[sS]$ ]]; then
                        ejecutar_playbook "05_apagar_aula.yml"
                    fi
                    ;;
                2)
                    echo -ne "${YELLOW}¿Confirma el reinicio de todo el laboratorio? (s/N): ${RESET}"
                    read -r conf_reb
                    if [[ "$conf_reb" =~ ^[sS]$ ]]; then
                        ejecutar_playbook "07_reiniciar_aula.yml"
                    fi
                    ;;
            esac
            ;;
        0)
            break
            ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done
