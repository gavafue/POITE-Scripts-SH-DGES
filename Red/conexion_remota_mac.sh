#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Distribuir y ejecutar script remoto vía SSH descubriendo IPs por dirección MAC
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📤 DISTRIBUCIÓN REMOTA POR MAC (ARP)" "Descubre equipos en la subred por dirección física y ejecuta tareas vía SSH"

if [[ ! -f "$ARCHIVO_MACS" ]] || [[ ! -s "$ARCHIVO_MACS" ]]; then
    imprimir_error "No se encontraron MACs registradas en $ARCHIVO_MACS"
    pausar
    exit 1
fi

if [[ ! -f "$SCRIPT_REMOTO" ]]; then
    imprimir_error "No se encontró el script remoto en: $SCRIPT_REMOTO"
    pausar
    exit 1
fi

interfaz=$(obtener_interfaz_activa)
echo -e "Interfaz activa para escaneo: ${BOLD}${CYAN}$interfaz${RESET}"
echo -e "Archivo de MACs: ${CYAN}$ARCHIVO_MACS${RESET}"
echo

# Dependencias requeridas
for pkg in arp-scan nmap sshpass openssh-client; do
    if ! command -v "$pkg" &>/dev/null; then
        echo -e "${YELLOW}Instalando dependencia necesaria: $pkg...${RESET}"
        sudo apt update && sudo apt install -y "$pkg" || true
    fi
done

read -p "👤 Usuario remoto: " usuario
read -s -p "🔐 Contraseña remota (dejar vacío si usa clave SSH): " clave
echo
echo

echo -e "${BOLD}🔍 Escaneando tabla ARP y vecinos de red...${RESET}"
sudo arp-scan --interface="$interfaz" --localnet 2>/dev/null > /tmp/arp_scan_cache.txt || true

mapfile -t MACS < <(grep -iE '([0-9a-f]{2}:){5}[0-9a-f]{2}' "$ARCHIVO_MACS")

TOTAL=0
EXITOSOS=0
FALLIDOS=0

for mac in "${MACS[@]}"; do
    mac_clean=$(echo "$mac" | tr '[:upper:]' '[:lower:]' | xargs)
    [[ -z "$mac_clean" ]] && continue
    ((TOTAL++))

    echo -e "➡️  Buscando IP para MAC: ${BOLD}$mac_clean${RESET}"
    ip_hallada=$(awk -v mac="$mac_clean" 'tolower($2)==mac {print $1}' /tmp/arp_scan_cache.txt 2>/dev/null || true)
    
    if [[ -z "$ip_hallada" ]]; then
        ip_hallada=$(ip neigh | awk -v mac="$mac_clean" 'tolower($5)==mac {print $1}' | head -n1 || true)
    fi

    if [[ -z "$ip_hallada" ]]; then
        imprimir_error "No se encontró IP activa en la LAN para la MAC $mac_clean."
        ((FALLIDOS++))
        continue
    fi

    echo -e "   ${GREEN}Encontrado en IP:${RESET} $ip_hallada"

    # Copiar y ejecutar
    if [[ -n "$clave" ]]; then
        sshpass -p "$clave" scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$SCRIPT_REMOTO" "$usuario@$ip_hallada:/tmp/script_remoto.sh" &>/dev/null
        sshpass -p "$clave" ssh -o StrictHostKeyChecking=no "$usuario@$ip_hallada" "chmod +x /tmp/script_remoto.sh && PASSWORD='$clave' bash /tmp/script_remoto.sh && rm -f /tmp/script_remoto.sh"
    else
        scp -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$SCRIPT_REMOTO" "$usuario@$ip_hallada:/tmp/script_remoto.sh" &>/dev/null
        ssh -o BatchMode=yes -o StrictHostKeyChecking=no "$usuario@$ip_hallada" "chmod +x /tmp/script_remoto.sh && bash /tmp/script_remoto.sh && rm -f /tmp/script_remoto.sh"
    fi

    imprimir_exito "Tarea ejecutada en $ip_hallada ($mac_clean)"
    ((EXITOSOS++))
done

rm -f /tmp/arp_scan_cache.txt
echo
echo -e "${BOLD}Resumen de ejecución:${RESET} Total: $TOTAL | ${GREEN}Éxitos: $EXITOSOS${RESET} | ${RED}Fallos: $FALLIDOS${RESET}"
pausar