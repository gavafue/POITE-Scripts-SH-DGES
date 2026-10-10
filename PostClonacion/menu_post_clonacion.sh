#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Post-Clonación Día 1 - Asignación de Hostnames, Proxy DGES y Ansible
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
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
    echo -e "${CYAN}Ejecutando: $pb en todas las PCs del aula...${RESET}"
    echo "----------------------------------------------------------------------"
    if [[ -n "$extra_args" ]]; then
        ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/$pb" -e "$extra_args"
    else
        ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/$pb"
    fi
    echo "----------------------------------------------------------------------"
    pausar
}

asistente_puesta_a_punto_completa() {
    imprimir_encabezado "🚀 PUESTA A PUNTO INTEGRAL EN 1 CLIC (POST-CLONACIÓN)" "Prof. Gabriel Vázquez · Configuración guiada completa del aula"
    echo -e "${YELLOW}Este asistente automatizará todo el Día 1 en secuencia:${RESET}"
    echo -e "  1. 🗺️  Escaneará la red para detectar todas las PCs encendidas."
    echo -e "  2. 🏷️  Asignará nombres de host secuenciales (ej: lab1-pc01... lab1-pc25)."
    echo -e "  3. 🛡️  Desplegará el Proxy Institucional DGES en todas las máquinas."
    echo -e "  4. 🧪 Probará que todas las máquinas tengan salida real a Internet."
    echo -e "  5. 🕒 Sincronizará la fecha y la hora exacta en todo el laboratorio."
    echo
    echo -ne "¿Desea comenzar la puesta a punto automática ahora? (S/n): "
    read -r resp_run
    if [[ -n "$resp_run" && ! "$resp_run" =~ ^[sS]$ ]]; then
        imprimir_info "Operación cancelada."
        return 0
    fi

    # Paso 1: Mapeo de Red
    echo
    imprimir_info "Fase 1/5: Escaneando computadoras del aula..."
    bash "$BASE_DIR/Red/mapear_red_equipos.sh"

    # Paso 2: Asignación de Hostnames
    echo
    imprimir_info "Fase 2/5: Asignando nombres secuenciales (lab1-pcXX)..."
    bash "$BASE_DIR/Red/asignar_hostname.sh" <<< "3"

    # Paso 3: Despliegue de Proxy DGES
    echo
    imprimir_info "Fase 3/5: Desplegando Proxy DGES masivamente..."
    ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/09_configurar_proxy_aula.yml"

    # Paso 4: Verificación de Internet
    echo
    imprimir_info "Fase 4/5: Comprobando salida a Internet vía Proxy..."
    ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/06_verificar_proxy_internet.yml"

    # Paso 5: Sincronización de Reloj
    echo
    imprimir_info "Fase 5/5: Sincronizando hora y fecha del laboratorio..."
    ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/02_sincronizar_reloj.yml"

    echo
    imprimir_exito "¡Puesta a punto finalizada! Todas las computadoras tienen nombre, proxy, hora e Internet."
    pausar
}

while true; do
    imprimir_encabezado "🚀 POST-CLONACIÓN DÍA 1: ASIGNACIÓN Y CONTROL CON ANSIBLE" "Prof. Gabriel Vázquez (INET / ANEP) · Tareas iniciales tras clonar con Clonezilla"

    echo -e "  ${GREEN}1)${RESET}  🌟 ${BOLD}PUESTA A PUNTO INTEGRAL EN 1 CLIC (Piloto Automático)${RESET}"
    echo -e "         ${CYAN}(Mapeo + Hostnames lab1-pcXX + Proxy DGES + Internet + Reloj en secuencia)${RESET}"
    echo
    echo -e "  ${GREEN}2)${RESET}  🗺️  Mapear red y detectar equipos recién encendidos en el aula"
    echo -e "  ${GREEN}3)${RESET}  🏷️  Asignación masiva secuencial de Hostnames (lab1-pc01... lab1-pc30)"
    echo -e "  ${GREEN}4)${RESET}  🛡️  ${BOLD}Habilitar Internet: Desplegar Proxy DGES en todo el laboratorio${RESET}"
    echo -e "  ${GREEN}5)${RESET}  🧪 Probar conectividad a Internet y Proxy en todas las PCs del aula"
    echo -e "  ${GREEN}6)${RESET}  🕒 Sincronizar reloj y zona horaria (Montevideo) en todo el aula"
    echo -e "  ${GREEN}7)${RESET}  📦 Actualizar repositorios y paquetes de software en lote ($PKG_MANAGER)"
    echo -e "  ${GREEN}8)${RESET}  📋 Ver / Editar inventario de Ansible del aula"
    echo -e "  ${GREEN}9)${RESET}  📢 Emitir mensaje o notificación a las pantallas de los estudiantes"
    echo -e "  ${YELLOW}10)${RESET} 🔌 Control de energía masivo (Apagar o reiniciar todo el aula)"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-10]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1)
            asistente_puesta_a_punto_completa
            ;;
        2)
            bash "$BASE_DIR/Red/mapear_red_equipos.sh"
            ;;
        3)
            bash "$BASE_DIR/Red/asignar_hostname.sh" <<< "3"
            ;;
        4)
            echo
            echo -e "${CYAN}Despliegue masivo del Proxy Institucional DGES en todas las PCs clonadas:${RESET}"
            echo -ne "Ingrese IP y puerto del proxy [Enter para 10.4.142.24:8080]: "
            read -r px_in
            px_val="${px_in:-10.4.142.24:8080}"
            ejecutar_playbook "09_configurar_proxy_aula.yml" "proxy_dges=$px_val"
            ;;
        5)
            ejecutar_playbook "06_verificar_proxy_internet.yml"
            ;;
        6)
            ejecutar_playbook "02_sincronizar_reloj.yml"
            ;;
        7)
            ejecutar_playbook "03_actualizar_paquetes.yml"
            ;;
        8)
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
        9)
            echo
            echo -ne "${CYAN}Ingrese el mensaje a transmitir a las terminales del aula: ${RESET}"
            read -r texto_msg
            if [[ -n "$texto_msg" ]]; then
                ejecutar_playbook "08_notificar_alumnos.yml" "mensaje=$texto_msg"
            fi
            ;;
        10)
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
