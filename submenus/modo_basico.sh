#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Modo Básico / Asistido: Diseñado para docentes con poca experiencia en Linux
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

DIR_ANSIBLE="$BASE_DIR/ansible"
DIR_PLAYBOOKS="$DIR_ANSIBLE/playbooks"
INVENTARIO_INI="$DIR_DATOS/inventario_ansible.ini"

acciones_rapidas_dia() {
    while true; do
        imprimir_encabezado "⚡ ACCIONES RÁPIDAS DEL DÍA A DÍA" "Prof. Gabriel Vázquez · Tareas frecuentes en 1 solo paso"
        echo -e "  ${GREEN}1)${RESET} 🔌 Apagar todas las computadoras del aula al terminar el turno"
        echo -e "  ${GREEN}2)${RESET} 🔄 Reiniciar todas las computadoras del aula"
        echo -e "  ${GREEN}3)${RESET} 🕒 Corregir la hora y fecha en todo el aula (Solución error de certificados)"
        echo -e "  ${GREEN}4)${RESET} 📢 Enviar un aviso o mensaje a las pantallas de los estudiantes"
        echo -e "  ${GREEN}5)${RESET} 🌐 Probar si hay Internet en las computadoras del aula"
        echo -e "  ${RED}0)${RESET} 🔙 Volver"
        echo
        echo -ne "${BOLD}Seleccione una acción [0-5]: ${RESET}"
        read -r act_opt

        case "$act_opt" in
            1)
                echo -ne "${RED}¿Seguro que desea APAGAR todas las computadoras del aula? (s/N): ${RESET}"
                read -r conf_off
                if [[ "$conf_off" =~ ^[sS]$ ]]; then
                    ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/05_apagar_aula.yml"
                    pausar
                fi
                ;;
            2)
                echo -ne "${YELLOW}¿Desea REINICIAR todas las computadoras del aula? (s/N): ${RESET}"
                read -r conf_reb
                if [[ "$conf_reb" =~ ^[sS]$ ]]; then
                    ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/07_reiniciar_aula.yml"
                    pausar
                fi
                ;;
            3)
                echo -e "${CYAN}Sincronizando reloj en todo el laboratorio...${RESET}"
                ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/02_sincronizar_reloj.yml"
                pausar
                ;;
            4)
                echo -ne "${CYAN}Escriba el mensaje para los estudiantes: ${RESET}"
                read -r msg_est
                if [[ -n "$msg_est" ]]; then
                    ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/08_notificar_alumnos.yml" -e "mensaje=$msg_est"
                    pausar
                fi
                ;;
            5)
                echo -e "${CYAN}Comprobando Internet en todas las computadoras...${RESET}"
                ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/06_verificar_proxy_internet.yml"
                pausar
                ;;
            0)
                break
                ;;
        esac
    done
}

while true; do
    IP_LOCAL=$(obtener_ip_local)
    HOSTNAME_ACTUAL=$(hostname 2>/dev/null || echo "localhost")
    USUARIO_ACTUAL=$(whoami 2>/dev/null || echo "usuario")

    clear
    echo -e "${BLUE}======================================================================${RESET}"
    echo -e "${BOLD}${CYAN}   🖥️  ASISTENTE POITE · MODO ASISTIDO (NIVEL BÁSICO)${RESET}"
    echo -e "   ${YELLOW}Prof. Gabriel Vázquez · Docente de Informática (INET / ANEP)${RESET}"
    echo -e "${BLUE}======================================================================${RESET}"
    echo -e "   ${BOLD}💻 Equipo:${RESET}  ${GREEN}${HOSTNAME_ACTUAL}${RESET}   |   ${BOLD}👤 Usuario:${RESET} ${MAGENTA}${USUARIO_ACTUAL}${RESET}"
    echo -e "   ${BOLD}🌐 IP:${RESET}      ${YELLOW}${IP_LOCAL}${RESET}      |   ${BOLD}🎯 Nivel:${RESET}   ${GREEN}Básico (Guiado)${RESET}"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -e "${BOLD}Seleccione la tarea que desea realizar:${RESET}"
    echo
    echo -e "  ${GREEN}1)${RESET} 🏠 ${BOLD}Paso 1: Preparar Computadora de Prueba en Casa${RESET}"
    echo -e "     ${CYAN}Instala programas escolares, alumno, autologin y la deja lista para clonar.${RESET}"
    echo
    echo -e "  ${GREEN}2)${RESET} 🏫 ${BOLD}Paso 2: Poner a Punto el Aula tras Clonar (¡Piloto Automático!)${RESET}"
    echo -e "     ${CYAN}Detecta PCs, pone nombres tipo lab1-pcXX y activa Internet en todo el aula.${RESET}"
    echo
    echo -e "  ${GREEN}3)${RESET} ⚡ ${BOLD}Acciones Rápidas del Día a Día${RESET}"
    echo -e "     ${CYAN}Apagar aula, reiniciar, corregir hora o mandar mensajes a alumnos.${RESET}"
    echo
    echo -e "  ${YELLOW}4)${RESET} 🎯 ${BOLD}Cambiar Nivel de Experiencia${RESET} (Pasar a Intermedio o Avanzado)"
    echo
    echo -e "  ${RED}0)${RESET} 🚪 ${BOLD}Salir${RESET}"
    echo -e "${BLUE}======================================================================${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-4]: ${RESET}"
    read -r opt_basica

    case "$opt_basica" in
        1)
            bash "$BASE_DIR/ImagenMaestra/preparar_imagen_maestra.sh"
            ;;
        2)
            bash "$BASE_DIR/PostClonacion/menu_post_clonacion.sh" <<< "1"
            ;;
        3)
            acciones_rapidas_dia
            ;;
        4)
            seleccionar_nivel_poite_dialogo
            # Si el nivel cambió y ya no es 1, salimos de este submenú para que el menú principal cargue el nuevo
            if [[ "$(obtener_nivel_poite)" != "1" ]]; then
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
