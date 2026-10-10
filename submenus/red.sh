#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Red y Conectividad
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "🌐 RED Y CONECTIVIDAD INSTITUCIONAL" "Gestione diagnóstico, proxy institucional y acceso remoto en el aula"
    
    echo -e "  ${GREEN}1)${RESET}  ⚡ Diagnóstico rápido de conectividad y DNS"
    echo -e "  ${GREEN}2)${RESET}  🗺️  Mapear red y detectar equipos del aula (${BOLD}lab1-pcXX${RESET})"
    echo -e "  ${GREEN}3)${RESET}  🏷️  Asignar Hostname a equipos (local, remoto o lote ${BOLD}lab1-pcXX${RESET})"
    echo -e "  ${GREEN}4)${RESET}  🚀 Aprovisionamiento express de SSH en el aula (Servidor HTTP / Pendrive)"
    echo -e "  ${GREEN}5)${RESET}  🤖 Automatización masiva con Ansible (ping, reloj, paquetes, apagado)"
    echo -e "  ${GREEN}6)${RESET}  🛡️  Gestor de Proxy Institucional DGES (Activar, cambiar o desactivar)"
    echo -e "  ${GREEN}7)${RESET}  🔄 Reiniciar servicios de red (NetworkManager)"
    echo -e "  ${GREEN}8)${RESET}  📤 Distribuir y ejecutar script remoto vía SSH (por IP o MAC)"
    echo -e "  ${GREEN}9)${RESET}  📋 Administrar registros de red (Ver IPs, MACs y vaciado seguro)"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-9]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/Red/diagnostico_red.sh" ;;
        2) bash "$BASE_DIR/Red/mapear_red_equipos.sh" ;;
        3) bash "$BASE_DIR/Red/asignar_hostname.sh" ;;
        4) bash "$BASE_DIR/Red/despliegue_ssh_aula.sh" ;;
        5) bash "$BASE_DIR/Red/ejecutar_ansible_aula.sh" ;;
        6) bash "$BASE_DIR/Red/proxy_DGES.sh" ;;
        7) bash "$BASE_DIR/Red/reiniciar_red.sh" ;;
        8) bash "$BASE_DIR/Red/conexion_remota.sh" ;;
        9) bash "$BASE_DIR/Red/gestor_registros_red.sh" ;;
        0) break ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done