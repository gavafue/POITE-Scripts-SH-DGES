#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Ejecución Remota Unificada de Scripts en el Laboratorio (SSH por IP o MAC)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📤 EJECUCIÓN REMOTA DE SCRIPTS EN EL AULA" "Distribuya y ejecute tareas en computadoras del aula mediante SSH"

if [[ ! -f "$SCRIPT_REMOTO" ]]; then
    mkdir -p "$DIR_DATOS"
    cat > "$SCRIPT_REMOTO" <<'EOF'
#!/bin/bash
echo "=== Ejecución remota iniciada en: $(hostname) ($(date)) ==="
echo "• Uptime: $(uptime -p 2>/dev/null || uptime)"
echo "• Espacio libre: $(df -h / | awk 'NR==2 {print $4}')"
echo "=== Finalizado con éxito ==="
EOF
    chmod +x "$SCRIPT_REMOTO"
fi

echo -e "Script remoto a ejecutar: ${BOLD}${CYAN}$SCRIPT_REMOTO${RESET}"
echo -e "Seleccione el método de distribución hacia los puestos:"
echo -e "  ${GREEN}1)${RESET} 🌐 Ejecutar en todas las IPs registradas ($ARCHIVO_IPS)"
echo -e "  ${GREEN}2)${RESET} 🏷️  Ejecutar en equipos por dirección MAC ($ARCHIVO_MACS)"
echo -e "  ${GREEN}3)${RESET} 🎯 Ejecutar en una sola IP específica"
echo -e "  ${YELLOW}4)${RESET} ✏️  Ver / Editar contenido de '$SCRIPT_REMOTO'"
echo -e "  ${RED}0)${RESET} 🔙 Cancelar y volver"
echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-4]: ${RESET}"
read -r opcion

ejecutar_en_ip() {
    local ip="$1"
    local user="$2"
    printf "• Conectando a %-16s ... " "$ip"
    
    if ! ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
        echo -e "${RED}NO RESPONDE A PING${RESET}"
        return 1
    fi

    # Enviar y ejecutar remoto
    if ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=no "$user@$ip" "bash -s" < "$SCRIPT_REMOTO" >> "$ARCHIVO_LOG" 2>&1; then
        echo -e "${GREEN}ÉXITO${RESET}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] OK: $ip por $user" >> "$ARCHIVO_LOG"
        return 0
    else
        # Intentar interactivo si falla BatchMode
        if ssh -o ConnectTimeout=4 -o StrictHostKeyChecking=no "$user@$ip" "bash -s" < "$SCRIPT_REMOTO" 2>/dev/null; then
            echo -e "${GREEN}ÉXITO${RESET}"
            return 0
        else
            echo -e "${RED}FALLO SSH (Verifique clave o permisos)${RESET}"
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $ip" >> "$ARCHIVO_LOG"
            return 1
        fi
    fi
}

case "$opcion" in
    1)
        if [[ ! -f "$ARCHIVO_IPS" ]] || [[ ! -s "$ARCHIVO_IPS" ]]; then
            imprimir_error "No hay IPs registradas en $ARCHIVO_IPS. Registre o mapee la red primero."
            pausar
            exit 1
        fi

        echo
        echo -ne "${CYAN}Usuario SSH para conectar a los equipos [Enter para '$(whoami)']: ${RESET}"
        read -r u_input
        USER_SSH="${u_input:-$(whoami)}"

        echo
        echo -e "${BOLD}Iniciando distribución en lote...${RESET}"
        echo "----------------------------------------------------------------------"
        EXITOS=0
        FALLOS=0
        while read -r ip; do
            ip=$(echo "$ip" | tr -d '\r\n' | xargs)
            [[ -z "$ip" || "$ip" =~ ^# ]] && continue
            if ejecutar_en_ip "$ip" "$USER_SSH"; then
                ((EXITOS++))
            else
                ((FALLOS++))
            fi
        done < "$ARCHIVO_IPS"
        echo "----------------------------------------------------------------------"
        echo -e "${BOLD}Resumen:${RESET} Exitosos: ${GREEN}$EXITOS${RESET} | Fallidos: ${RED}$FALLOS${RESET}"
        imprimir_info "Registro guardado en: $ARCHIVO_LOG"
        pausar
        ;;

    2)
        if [[ ! -f "$ARCHIVO_MACS" ]] || [[ ! -s "$ARCHIVO_MACS" ]]; then
            imprimir_error "No hay MACs registradas en $ARCHIVO_MACS."
            pausar
            exit 1
        fi

        echo
        echo -ne "${CYAN}Usuario SSH para conectar [Enter para '$(whoami)']: ${RESET}"
        read -r u_input
        USER_SSH="${u_input:-$(whoami)}"

        echo
        echo -e "${CYAN}Resolviendo direcciones MAC en la tabla ARP de la red local...${RESET}"
        echo "----------------------------------------------------------------------"
        EXITOS=0
        FALLOS=0

        while read -r mac; do
            mac=$(echo "$mac" | tr -d '\r\n' | tr '[:upper:]' '[:lower:]' | xargs)
            [[ -z "$mac" || "$mac" =~ ^# ]] && continue

            # Buscar IP asociada a la MAC
            ip=$(ip neigh | grep -i "$mac" | awk '{print $1}' | head -n1 || true)
            if [[ -z "$ip" ]]; then
                # Intentar en arp
                ip=$(arp -an 2>/dev/null | grep -i "$mac" | grep -oP '\(\K[0-9.]+(?=\))' | head -n1 || true)
            fi

            if [[ -n "$ip" ]]; then
                printf "• MAC %s -> IP %-15s ... " "$mac" "$ip"
                if ejecutar_en_ip "$ip" "$USER_SSH"; then
                    ((EXITOS++))
                else
                    ((FALLOS++))
                fi
            else
                echo -e "• MAC ${YELLOW}$mac${RESET} ... ${RED}NO DETECTADA EN LA TABLA ARP (Posiblemente apagada)${RESET}"
                ((FALLOS++))
            fi
        done < "$ARCHIVO_MACS"
        echo "----------------------------------------------------------------------"
        echo -e "${BOLD}Resumen:${RESET} Exitosos: ${GREEN}$EXITOS${RESET} | Fallidos: ${RED}$FALLOS${RESET}"
        pausar
        ;;

    3)
        echo
        echo -ne "${CYAN}Ingrese la dirección IP del equipo: ${RESET}"
        read -r ip_target
        echo -ne "${CYAN}Usuario SSH [Enter para '$(whoami)']: ${RESET}"
        read -r u_input
        USER_SSH="${u_input:-$(whoami)}"

        echo
        ejecutar_en_ip "$ip_target" "$USER_SSH"
        pausar
        ;;

    4)
        EDITOR_CMD="${EDITOR:-nano}"
        if ! command -v nano >/dev/null 2>&1; then
            EDITOR_CMD="vi"
        fi
        $EDITOR_CMD "$SCRIPT_REMOTO"
        ;;

    0)
        ;;
    *)
        imprimir_error "Opción no válida."
        ;;
esac
