#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Mapeo de Red y Detección de Equipos del Laboratorio (tipo lab1-pc01)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🗺️ MAPEO DE RED Y DETECCIÓN DE EQUIPOS" "Escanea el aula, detecta nombres tipo lab1-pcXX y genera inventario"

if ! asegurar_root; then
    exit 1
fi

IFACE=$(obtener_interfaz_activa)
SUBRED_DEFAULT=$(obtener_subred_local)
IP_LOCAL=$(obtener_ip_local)

echo -e "Interfaz activa detectada: ${BOLD}${CYAN}$IFACE${RESET} (IP local: ${GREEN}$IP_LOCAL${RESET})"
echo -ne "${BOLD}Ingrese la subred a escanear [Enter para usar $SUBRED_DEFAULT]: ${RESET}"
read -r subred_input
SUBRED="${subred_input:-$SUBRED_DEFAULT}"

echo
echo -e "Patrón de hostname del laboratorio (ejemplos: ${YELLOW}lab1-pc*${RESET}, ${YELLOW}lab*-pc*${RESET}, ${YELLOW}pc-*${RESET}):"
echo -ne "${BOLD}Ingrese el patrón a identificar [Enter para 'lab1-pc*']: ${RESET}"
read -r patron_input
PATRON_LAB="${patron_input:-lab1-pc*}"

echo
echo -e "${CYAN}Iniciando descubrimiento en la red $SUBRED...${RESET}"

# Verificar si nmap está instalado
USAR_NMAP=false
if command -v nmap >/dev/null 2>&1; then
    USAR_NMAP=true
else
    echo -e "${YELLOW}nmap no está instalado en este equipo.${RESET}"
    echo -e "  [1] Instalar nmap para un escaneo más rápido y preciso (Recomendado)"
    echo -e "  [2] Continuar con escaneo nativo paralelo en Bash (Ping sweep + ARP)"
    echo -ne "${BOLD}Seleccione una opción [1/2]: ${RESET}"
    read -r opt_nmap
    if [[ "$opt_nmap" == "1" ]]; then
        instalar_paquetes nmap
        if command -v nmap >/dev/null 2>&1; then
            USAR_NMAP=true
        fi
    fi
fi

# Listas de resultados
declare -A HOSTS_IP
declare -A HOSTS_MAC
declare -A HOSTS_NAME
declare -A HOSTS_ES_LAB

echo
echo -e "${CYAN}🔍 Escaneando equipos activos en la red... Por favor espere unos segundos.${RESET}"

if [[ "$USAR_NMAP" = true ]]; then
    # Escaneo rápido con nmap
    TEMP_NMAP=$(mktemp)
    sudo nmap -sn "$SUBRED" -oG "$TEMP_NMAP" >/dev/null 2>&1

    while read -r line; do
        if echo "$line" | grep -q "Status: Up"; then
            ip=$(echo "$line" | awk '{print $2}')
            name=$(echo "$line" | awk -F'[()]' '{print $2}')
            [[ -z "$name" ]] && name=$(resolver_hostname_ip "$ip")
            name=$(echo "$name" | sed 's/\.local$//' | cut -d'.' -f1)

            # Extraer MAC de ARP
            mac=$(ip neigh show "$ip" 2>/dev/null | awk '{print $5}' | grep -E '^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$' || echo "N/A")
            [[ -z "$mac" ]] && mac="N/A"

            HOSTS_IP["$ip"]="$ip"
            HOSTS_NAME["$ip"]="${name:-desconocido}"
            HOSTS_MAC["$ip"]="$mac"
        fi
    done < "$TEMP_NMAP"
    rm -f "$TEMP_NMAP"
else
    # Escaneo nativo por ping sweep en segundo plano
    RED_BASE=$(echo "$SUBRED" | cut -d'/' -f1 | cut -d'.' -f1-3)
    for i in $(seq 1 254); do
        ping -c 1 -W 1 "$RED_BASE.$i" >/dev/null 2>&1 &
    done
    wait

    # Leer tabla de vecinos ARP
    while read -r ip _ _ mac _ estado; do
        if [[ "$estado" =~ (REACHABLE|DELAY|STALE) && "$mac" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
            name=$(resolver_hostname_ip "$ip")
            HOSTS_IP["$ip"]="$ip"
            HOSTS_NAME["$ip"]="${name:-desconocido}"
            HOSTS_MAC["$ip"]="$mac"
        fi
    done < <(ip neigh show dev "$IFACE" 2>/dev/null)
fi

# Incluir equipo local si no está en la lista
if [[ -z "${HOSTS_IP[$IP_LOCAL]}" ]]; then
    MAC_LOCAL=$(cat "/sys/class/net/$IFACE/address" 2>/dev/null || echo "N/A")
    HOSTS_IP["$IP_LOCAL"]="$IP_LOCAL"
    HOSTS_NAME["$IP_LOCAL"]="$(hostname)"
    HOSTS_MAC["$IP_LOCAL"]="$MAC_LOCAL"
fi

TOTAL_ENCONTRADOS=${#HOSTS_IP[@]}

if [[ $TOTAL_ENCONTRADOS -eq 0 ]]; then
    imprimir_error "No se encontraron equipos respondiendo en la subred $SUBRED."
    pausar
    exit 0
fi

echo
echo -e "${BLUE}======================================================================${RESET}"
echo -e "${BOLD}${CYAN}   RESULTADOS DEL MAPEO DE RED (${TOTAL_ENCONTRADOS} dispositivos detectados)${RESET}"
echo -e "${BLUE}======================================================================${RESET}"
printf "%-17s %-19s %-22s %-15s\n" "DIRECCIÓN IP" "DIRECCIÓN MAC" "HOSTNAME" "ESTADO"
echo "----------------------------------------------------------------------"

TOTAL_LAB=0
TOTAL_OTROS=0
NUMEROS_PC=()

# Ordenar por IP numérica
IPS_ORDENADAS=$(for ip in "${!HOSTS_IP[@]}"; do echo "$ip"; done | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n)

for ip in $IPS_ORDENADAS; do
    mac="${HOSTS_MAC[$ip]:-N/A}"
    name="${HOSTS_NAME[$ip]:-desconocido}"

    # Evaluar si coincide con el patrón del aula
    shopt -s nocasematch
    if [[ "$name" == $PATRON_LAB ]]; then
        estado="${GREEN}🎓 LABORATORIO${RESET}"
        HOSTS_ES_LAB["$ip"]=true
        ((TOTAL_LAB++))

        # Extraer número si existe al final del hostname (ej: lab1-pc04 -> 4)
        num=$(echo "$name" | grep -oP '[0-9]+$' || true)
        if [[ -n "$num" ]]; then
            NUMEROS_PC+=("$((10#$num))")
        fi
    else
        estado="${YELLOW}📱 OTRO EQUIPO${RESET}"
        HOSTS_ES_LAB["$ip"]=false
        ((TOTAL_OTROS++))
    fi
    shopt -u nocasematch

    printf "%-17s %-19s %-22s %b\n" "$ip" "$mac" "$name" "$estado"
done
echo "----------------------------------------------------------------------"
echo -e "${BOLD}Resumen:${RESET} Equipos identificados del aula: ${GREEN}${TOTAL_LAB}${RESET} | Otros dispositivos en red: ${YELLOW}${TOTAL_OTROS}${RESET}"

# Análisis de secuencia de PCs faltantes
if [[ ${#NUMEROS_PC[@]} -gt 1 ]]; then
    # Ordenar números
    IFS=$'\n' NUMS_SORTED=($(sort -n <<<"${NUMEROS_PC[*]}"))
    unset IFS

    MIN_PC=${NUMS_SORTED[0]}
    MAX_PC=${NUMS_SORTED[-1]}
    FALTANTES=()

    for ((n=MIN_PC; n<=MAX_PC; n++)); do
        presente=false
        for x in "${NUMS_SORTED[@]}"; do
            if [[ $x -eq $n ]]; then
                presente=true
                break
            fi
        done
        if [[ "$presente" = false ]]; then
            FALTANTES+=("$n")
        fi
    done

    if [[ ${#FALTANTES[@]} -gt 0 ]]; then
        echo
        echo -e "${YELLOW}⚠️  ALERTA DE SECUENCIA: Hay computadoras del aula no detectadas entre PC ${MIN_PC} y PC ${MAX_PC}:${RESET}"
        PREFIJO_SUG=$(echo "$PATRON_LAB" | tr -d '*')
        for f in "${FALTANTES[@]}"; do
            printf "   • %s%02d (Posiblemente apagada o desconectada)\n" "$PREFIJO_SUG" "$f"
        done
    else
        echo
        imprimir_exito "Secuencia completa: Todas las computadoras entre PC $MIN_PC y PC $MAX_PC respondieron en red."
    fi
fi

# Acciones de exportación
echo
echo -e "${BOLD}${MAGENTA}¿Qué desea hacer con estos resultados?${RESET}"
echo -e "  ${GREEN}1)${RESET} Guardar IPs en '$ARCHIVO_IPS' y reporte detallado en '$DIR_DATOS/inventario_laboratorio.txt'"
echo -e "  ${GREEN}2)${RESET} Generar Inventario de Ansible ('$DIR_DATOS/inventario_ansible.ini')"
echo -e "  ${GREEN}3)${RESET} Realizar ambas exportaciones (Inventario general + Ansible)"
echo -e "  ${RED}0)${RESET} Continuar sin guardar"
echo -ne "${BOLD}Seleccione una opción [0-3]: ${RESET}"
read -r opt_guardar

guardar_inventario_txt() {
    mkdir -p "$DIR_DATOS"
    local reporte="$DIR_DATOS/inventario_laboratorio.txt"
    {
        echo "=============================================================================="
        echo "INVENTARIO DE LABORATORIO DE INFORMÁTICA - DGES URUGUAY"
        echo "Fecha de escaneo: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Subred: $SUBRED | Interfaz: $IFACE"
        echo "=============================================================================="
        printf "%-18s %-20s %-24s %-15s\n" "IP" "MAC" "HOSTNAME" "TIPO"
        echo "------------------------------------------------------------------------------"
        for ip in $IPS_ORDENADAS; do
            local mac="${HOSTS_MAC[$ip]:-N/A}"
            local name="${HOSTS_NAME[$ip]:-desconocido}"
            local tipo="OTRO"
            [[ "${HOSTS_ES_LAB[$ip]}" = true ]] && tipo="LABORATORIO"
            printf "%-18s %-20s %-24s %-15s\n" "$ip" "$mac" "$name" "$tipo"
        done
    } > "$reporte"

    # Guardar IPs en ips.txt
    for ip in $IPS_ORDENADAS; do
        if ! grep -Fxq "$ip" "$ARCHIVO_IPS" 2>/dev/null; then
            echo "$ip" >> "$ARCHIVO_IPS"
        fi
    done
    imprimir_exito "Inventario guardado en $reporte y $ARCHIVO_IPS."
}

guardar_ansible_ini() {
    mkdir -p "$DIR_DATOS"
    local ini_file="$DIR_DATOS/inventario_ansible.ini"
    {
        echo "# =============================================================================="
        echo "# INVENTARIO DE ANSIBLE - LABORATORIO DE INFORMÁTICA"
        echo "# Generado automáticamente por Asistente POITE: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# =============================================================================="
        echo
        echo "[laboratorio]"
        for ip in $IPS_ORDENADAS; do
            local name="${HOSTS_NAME[$ip]:-pc}"
            if [[ "${HOSTS_ES_LAB[$ip]}" = true ]]; then
                echo "$name ansible_host=$ip"
            fi
        done
        echo
        echo "[otros_equipos]"
        for ip in $IPS_ORDENADAS; do
            local name="${HOSTS_NAME[$ip]:-dispositivo}"
            if [[ "${HOSTS_ES_LAB[$ip]}" = false ]]; then
                echo "$name ansible_host=$ip"
            fi
        done
        echo
        echo "[laboratorio:vars]"
        echo "ansible_user=docente"
        echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
    } > "$ini_file"
    imprimir_exito "Inventario de Ansible generado en $ini_file."
}

case "$opt_guardar" in
    1)
        guardar_inventario_txt
        ;;
    2)
        guardar_ansible_ini
        ;;
    3)
        guardar_inventario_txt
        guardar_ansible_ini
        ;;
    *)
        imprimir_info "Resultados visualizados sin guardar."
        ;;
esac

pausar
