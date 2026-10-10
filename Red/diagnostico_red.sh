#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Diagnóstico Rápido de Red y Estado del Equipo
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "⚡ DIAGNÓSTICO RÁPIDO DEL EQUIPO Y RED" "Verificando conectividad y recursos críticos del laboratorio..."

echo -e "${BOLD}1. Interfaces y Direccionamiento IP:${RESET}"
IFACE=$(obtener_interfaz_activa)
IP_LOCAL=$(obtener_ip_local)
MAC_LOCAL=$(cat "/sys/class/net/$IFACE/address" 2>/dev/null || echo "N/A")
GATEWAY=$(ip route | awk '/default/ {print $3}' | head -n1 || echo "N/A")

echo "   • Interfaz activa:  $IFACE"
echo "   • Dirección IP:     $IP_LOCAL"
echo "   • Dirección MAC:    $MAC_LOCAL"
echo "   • Puerta de enlace: $GATEWAY"
echo

echo -e "${BOLD}2. Pruebas de Conectividad:${RESET}"

# Test Gateway LAN
if [[ "$GATEWAY" != "N/A" ]]; then
    if ping -c 1 -W 2 "$GATEWAY" &>/dev/null; then
        imprimir_exito "Conexión a la red local (Gateway $GATEWAY): OK"
    else
        imprimir_error "Fallo al conectar con la puerta de enlace local ($GATEWAY)"
    fi
else
    imprimir_aviso "No se detectó puerta de enlace predeterminada."
fi

# Test Internet Directo (IP)
if ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    imprimir_exito "Conexión a Internet externa (ICMP / IP): OK"
else
    imprimir_error "Sin salida directa a Internet por IP (posible bloqueo o desconexión)"
fi

# Test Resolución DNS
if ping -c 1 -W 3 google.com &>/dev/null; then
    imprimir_exito "Resolución de Nombres (DNS): OK"
else
    imprimir_aviso "Falla la resolución DNS (verifique /etc/resolv.conf o configuración del router)"
fi

# Test Plataformas Educativas Nacionales
if ping -c 1 -W 3 ceibal.edu.uy &>/dev/null || curl -sI --connect-timeout 3 https://ceibal.edu.uy &>/dev/null; then
    imprimir_exito "Acceso a servidores de Ceibal (ceibal.edu.uy): OK"
else
    imprimir_info "Servidor Ceibal no responde por ping (posible filtro de firewall del centro)."
fi

echo
echo -e "${BOLD}3. Espacio en Disco Raíz (/):${RESET}"
USO_DISCO=$(df -h / | awk 'NR==2 {print $5 " ocupado (" $4 " libres de " $2 ")"}')
PORCENTAJE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if (( PORCENTAJE > 90 )); then
    imprimir_error "Espacio en disco crítico: $USO_DISCO. Se recomienda realizar mantenimiento."
elif (( PORCENTAJE > 75 )); then
    imprimir_aviso "Espacio en disco moderado: $USO_DISCO"
else
    imprimir_exito "Espacio en disco saludable: $USO_DISCO"
fi

echo
echo -e "${BOLD}4. Sincronización del Reloj del Sistema:${RESET}"
HORA_ACTUAL=$(date "+%d/%m/%Y %H:%M:%S")
ZONA_ACTUAL=$(timedatectl 2>/dev/null | grep -i "time zone" | awk '{print $3}' || echo "N/A")
echo "   • Fecha y hora local: $HORA_ACTUAL"
echo "   • Zona horaria:       $ZONA_ACTUAL"

if timedatectl 2>/dev/null | grep -iq "NTP service: active"; then
    imprimir_exito "Servicio de sincronización NTP activo."
else
    imprimir_info "Servicio NTP no reportado activo por systemd."
fi

pausar
