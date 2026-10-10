#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Lanzador de Automatización con Ansible para el Laboratorio
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🤖 GESTIÓN MASIVA CON ANSIBLE EN EL AULA" "Ejecute tareas simultáneas en todas las PCs del laboratorio"

if ! command -v ansible >/dev/null 2>&1; then
    imprimir_aviso "Ansible no se encuentra instalado en este equipo."
    echo -ne "¿Desea instalar y configurar Ansible ahora? (S/n): "
    read -r resp_inst
    if [[ -z "$resp_inst" || "$resp_inst" =~ ^[sS]$ ]]; then
        bash "$BASE_DIR/InstalacionesFrecuentes/instalar_ansible.sh"
    else
        exit 0
    fi
fi

DIR_ANSIBLE="$BASE_DIR/ansible"
DIR_PLAYBOOKS="$DIR_ANSIBLE/playbooks"
INVENTARIO_INI="$DIR_DATOS/inventario_ansible.ini"

if [[ ! -f "$INVENTARIO_INI" ]]; then
    imprimir_aviso "No se encontró el inventario '$INVENTARIO_INI'."
    echo -e "Se sugiere mapear la red primero para detectar los equipos del aula."
    echo -ne "¿Desea ejecutar el mapeo de red ahora? (S/n): "
    read -r resp_map
    if [[ -z "$resp_map" || "$resp_map" =~ ^[sS]$ ]]; then
        bash "$BASE_DIR/Red/mapear_red_equipos.sh"
    else
        exit 0
    fi
fi

echo -e "${BOLD}Equipos configurados en el inventario ($INVENTARIO_INI):${RESET}"
grep -E "^[a-zA-Z0-9_-]+\s+ansible_host=" "$INVENTARIO_INI" 2>/dev/null | awk '{print "  • " $1 " (" $2 ")"}' || echo "  (Sin equipos definidos)"
echo

echo -e "Seleccione qué acción masiva desea ejecutar en el laboratorio:"
echo -e "  ${GREEN}1)${RESET} 📡 Probar conectividad (Ping Ansible a todas las PCs)"
echo -e "  ${GREEN}2)${RESET} 🕒 Sincronizar reloj y zona horaria (Montevideo) en todo el aula"
echo -e "  ${GREEN}3)${RESET} 📦 Actualizar repositorios y paquetes de software en lote"
echo -e "  ${GREEN}4)${RESET} 👤 Crear usuario estándar 'alumno' en todas las computadoras"
echo -e "  ${GREEN}5)${RESET} 🔌 Apagar todas las PCs del aula al finalizar la jornada"
echo -e "  ${GREEN}6)${RESET} ⌨️  Ejecutar comando ad-hoc en todo el laboratorio"
echo -e "  ${RED}0)${RESET} 🔙 Cancelar y volver"
echo
echo -ne "${BOLD}Seleccione una opción [0-6]: ${RESET}"
read -r opt_ans

ejecutar_playbook() {
    local pb="$1"
    echo
    echo -e "${CYAN}Ejecutando playbook: $pb...${RESET}"
    echo "----------------------------------------------------------------------"
    ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible-playbook -i "$INVENTARIO_INI" "$DIR_PLAYBOOKS/$pb"
    echo "----------------------------------------------------------------------"
}

case "$opt_ans" in
    1)
        ejecutar_playbook "01_ping_aula.yml"
        ;;
    2)
        ejecutar_playbook "02_sincronizar_reloj.yml"
        ;;
    3)
        ejecutar_playbook "03_actualizar_paquetes.yml"
        ;;
    4)
        ejecutar_playbook "04_crear_usuario_alumno.yml"
        ;;
    5)
        echo -e "${RED}⚠️  ATENCIÓN: Esto enviará la orden de apagado inmediato a todos los equipos del laboratorio.${RESET}"
        echo -ne "¿Está seguro de continuar? (s/N): "
        read -r conf_apagar
        if [[ "$conf_apagar" =~ ^[sS]$ ]]; then
            ejecutar_playbook "05_apagar_aula.yml"
        else
            imprimir_info "Operación cancelada."
        fi
        ;;
    6)
        echo
        echo -ne "${CYAN}Ingrese el comando a ejecutar en todas las PCs (ej: uptime / free -m): ${RESET}"
        read -r cmd_adhoc
        if [[ -n "$cmd_adhoc" ]]; then
            echo "----------------------------------------------------------------------"
            ANSIBLE_CONFIG="$DIR_ANSIBLE/ansible.cfg" ansible laboratorio -i "$INVENTARIO_INI" -m command -a "$cmd_adhoc"
            echo "----------------------------------------------------------------------"
        fi
        ;;
    0)
        imprimir_info "Operación cancelada."
        ;;
    *)
        imprimir_error "Opción no válida."
        ;;
esac

pausar
