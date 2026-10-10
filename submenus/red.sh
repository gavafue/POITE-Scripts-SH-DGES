#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Submenú: Red y Conectividad
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "🌐 RED Y CONECTIVIDAD INSTITUCIONAL" "Gestione diagnóstico, proxy institucional y acceso remoto en el aula"
    
    echo -e "  ${GREEN}1)${RESET}  📝 Registrar IP del equipo actual"
    echo -e "  ${GREEN}2)${RESET}  🛡️  Gestor de Proxy DGES (Configurar, verificar o desactivar)"
    echo -e "  ${GREEN}3)${RESET}  🔄 Reiniciar servicios de red (NetworkManager)"
    echo -e "  ${GREEN}4)${RESET}  ⚡ Diagnóstico rápido de conectividad y DNS"
    echo -e "  ${GREEN}5)${RESET}  📦 Verificar repositorios oficiales de la distribución ($PKG_MANAGER)"
    echo -e "  ${GREEN}6)${RESET}  🗺️  Mapear red y detectar equipos del aula (${BOLD}lab1-pcXX${RESET})"
    echo -e "  ${GREEN}7)${RESET}  🏷️  Asignar Hostname a equipos (local, remoto o lote ${BOLD}lab1-pcXX${RESET})"
    echo -e "  ${GREEN}8)${RESET}  🤖 Automatización masiva con Ansible (ping, reloj, paquetes, apagado)"
    echo -e "  ${GREEN}9)${RESET}  📤 Distribuir y ejecutar script remoto vía SSH (por IP)"
    echo -e "  ${GREEN}10)${RESET} 🧹 Limpiar archivo de IPs registradas"
    echo -e "  ${GREEN}11)${RESET} 🏷️  Registrar dirección MAC del equipo"
    echo -e "  ${GREEN}12)${RESET} 📤 Distribuir script remoto vía SSH (por MAC / ARP)"
    echo -e "  ${GREEN}13)${RESET} 🧹 Limpiar archivo de MACs registradas"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú principal"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-13]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1) bash "$BASE_DIR/Red/registrar_ip.sh" ;;
        2) bash "$BASE_DIR/Red/proxy_DGES.sh" ;;
        3) bash "$BASE_DIR/Red/reiniciar_red.sh" ;;
        4) bash "$BASE_DIR/Red/diagnostico_red.sh" ;;
        5) bash "$BASE_DIR/Red/chequear_repositorios_ubuntu20-04.sh" ;;
        6) bash "$BASE_DIR/Red/mapear_red_equipos.sh" ;;
        7) bash "$BASE_DIR/Red/asignar_hostname.sh" ;;
        8) bash "$BASE_DIR/Red/ejecutar_ansible_aula.sh" ;;
        9) bash "$BASE_DIR/Red/conexion_remota_ip.sh" ;;
        10) bash "$BASE_DIR/Red/limpiar_archivo_ip.sh" ;;
        11) bash "$BASE_DIR/Red/registrar_mac.sh" ;;
        12) bash "$BASE_DIR/Red/conexion_remota_mac.sh" ;;
        13) bash "$BASE_DIR/Red/limpiar_archivo_mac.sh" ;;
        0) break ;;
        *)
            imprimir_error "Opción no válida."
            sleep 1
            ;;
    esac
done