#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Gestor Unificado de Registros de Red (IPs, MACs e Inventario)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

while true; do
    imprimir_encabezado "📋 GESTOR DE REGISTROS DE RED E INVENTARIO" "Visualice, registre o limpie direcciones IP y MAC del laboratorio"

    TOTAL_IPS=0
    TOTAL_MACS=0
    [[ -f "$ARCHIVO_IPS" ]] && TOTAL_IPS=$(grep -c '[^[:space:]]' "$ARCHIVO_IPS" 2>/dev/null || echo 0)
    [[ -f "$ARCHIVO_MACS" ]] && TOTAL_MACS=$(grep -c '[^[:space:]]' "$ARCHIVO_MACS" 2>/dev/null || echo 0)

    echo -e "${BOLD}Estado actual de los registros:${RESET}"
    echo -e "   • Archivo de IPs:  ${CYAN}$ARCHIVO_IPS${RESET} (${GREEN}$TOTAL_IPS IPs registradas${RESET})"
    echo -e "   • Archivo de MACs: ${CYAN}$ARCHIVO_MACS${RESET} (${GREEN}$TOTAL_MACS MACs registradas${RESET})"
    echo -e "   • Script remoto:   ${CYAN}$SCRIPT_REMOTO${RESET}"
    echo

    echo -e "  ${GREEN}1)${RESET}  👁️  Ver listado de IPs registradas"
    echo -e "  ${GREEN}2)${RESET}  👁️  Ver listado de MACs registradas"
    echo -e "  ${GREEN}3)${RESET}  ➕ Registrar IP de ESTE equipo en la lista"
    echo -e "  ${GREEN}4)${RESET}  ➕ Registrar dirección MAC de ESTE equipo"
    echo -e "  ${GREEN}5)${RESET}  ✏️  Agregar una IP manualmente a la lista"
    echo -e "  ${YELLOW}6)${RESET}  🧹 Vaciar archivo de IPs registradas"
    echo -e "  ${YELLOW}7)${RESET}  🧹 Vaciar archivo de MACs registradas"
    echo -e "  ${RED}8)${RESET}  🗑️  Vaciar AMBOS archivos de registro"
    echo -e "  ${RED}0)${RESET}  🔙 Volver al menú anterior"
    echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
    echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-8]: ${RESET}"
    read -r opcion

    case "$opcion" in
        1)
            echo
            if [[ ! -f "$ARCHIVO_IPS" ]] || [[ $TOTAL_IPS -eq 0 ]]; then
                imprimir_info "El archivo de IPs está vacío."
            else
                echo -e "${BOLD}Direcciones IP registradas:${RESET}"
                nl -w2 -s") " "$ARCHIVO_IPS"
            fi
            pausar
            ;;
        2)
            echo
            if [[ ! -f "$ARCHIVO_MACS" ]] || [[ $TOTAL_MACS -eq 0 ]]; then
                imprimir_info "El archivo de MACs está vacío."
            else
                echo -e "${BOLD}Direcciones MAC registradas:${RESET}"
                nl -w2 -s") " "$ARCHIVO_MACS"
            fi
            pausar
            ;;
        3)
            IP_ACTUAL=$(obtener_ip_local)
            mkdir -p "$DIR_DATOS"
            if grep -Fxq "$IP_ACTUAL" "$ARCHIVO_IPS" 2>/dev/null; then
                imprimir_aviso "La IP $IP_ACTUAL ya se encuentra en el archivo."
            else
                echo "$IP_ACTUAL" >> "$ARCHIVO_IPS"
                imprimir_exito "IP $IP_ACTUAL agregada correctamente a $ARCHIVO_IPS."
            fi
            pausar
            ;;
        4)
            IFACE=$(obtener_interfaz_activa)
            MAC_ACTUAL=$(cat "/sys/class/net/$IFACE/address" 2>/dev/null || ip link show "$IFACE" | awk '/ether/ {print $2}')
            mkdir -p "$DIR_DATOS"
            if grep -Fxq "$MAC_ACTUAL" "$ARCHIVO_MACS" 2>/dev/null; then
                imprimir_aviso "La MAC $MAC_ACTUAL ya se encuentra registrada."
            else
                echo "$MAC_ACTUAL" >> "$ARCHIVO_MACS"
                imprimir_exito "MAC $MAC_ACTUAL agregada correctamente a $ARCHIVO_MACS."
            fi
            pausar
            ;;
        5)
            echo
            echo -ne "${CYAN}Ingrese la dirección IP a agregar: ${RESET}"
            read -r nueva_ip
            if [[ "$nueva_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                mkdir -p "$DIR_DATOS"
                if grep -Fxq "$nueva_ip" "$ARCHIVO_IPS" 2>/dev/null; then
                    imprimir_aviso "La IP $nueva_ip ya estaba registrada."
                else
                    echo "$nueva_ip" >> "$ARCHIVO_IPS"
                    imprimir_exito "IP $nueva_ip registrada correctamente."
                fi
            else
                imprimir_error "Formato de IP inválido."
            fi
            pausar
            ;;
        6)
            echo -ne "${YELLOW}¿Confirmar vaciado de $ARCHIVO_IPS? (s/N): ${RESET}"
            read -r r
            if [[ "$r" =~ ^[sS]$ ]]; then
                > "$ARCHIVO_IPS"
                imprimir_exito "Archivo de IPs vaciado correctamente."
            fi
            pausar
            ;;
        7)
            echo -ne "${YELLOW}¿Confirmar vaciado de $ARCHIVO_MACS? (s/N): ${RESET}"
            read -r r
            if [[ "$r" =~ ^[sS]$ ]]; then
                > "$ARCHIVO_MACS"
                imprimir_exito "Archivo de MACs vaciado correctamente."
            fi
            pausar
            ;;
        8)
            echo -ne "${RED}¿Confirmar vaciado total de IPs y MACs? (s/N): ${RESET}"
            read -r r
            if [[ "$r" =~ ^[sS]$ ]]; then
                > "$ARCHIVO_IPS" 2>/dev/null || true
                > "$ARCHIVO_MACS" 2>/dev/null || true
                imprimir_exito "Ambos archivos han sido vaciados."
            fi
            pausar
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
