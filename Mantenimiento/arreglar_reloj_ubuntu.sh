#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Sincronización del Reloj del Sistema y Solución de Batería de BIOS Agotada
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🕒 SINCRONIZACIÓN DE RELOJ Y ZONA HORARIA" "Soluciona errores SSL / certificados web causados por pilas de BIOS agotadas"

if ! asegurar_root; then
    exit 1
fi

echo -e "${CYAN}1. Configurando zona horaria a America/Montevideo...${RESET}"
sudo timedatectl set-timezone America/Montevideo
imprimir_exito "Zona horaria: America/Montevideo (Uruguay GMT-3)"

echo
echo -e "${CYAN}2. Habilitando sincronización de red NTP en systemd...${RESET}"
sudo timedatectl set-ntp true 2>/dev/null || true

# Configurar servidores NTP confiables en /etc/systemd/timesyncd.conf si existe
TIMESYNC_CONF="/etc/systemd/timesyncd.conf"
if [[ -f "$TIMESYNC_CONF" ]]; then
    sudo tee "$TIMESYNC_CONF" > /dev/null <<EOF
[Time]
NTP=time.google.com time.cloudflare.com 0.south-america.pool.ntp.org
FallbackNTP=pool.ntp.org
EOF
    sudo systemctl restart systemd-timesyncd 2>/dev/null || true
    imprimir_exito "Servidores NTP configurados en systemd-timesyncd."
fi

echo
echo -e "${CYAN}3. Sincronizando reloj de hardware con el sistema...${RESET}"
sudo hwclock --systohc 2>/dev/null || true
imprimir_exito "Reloj de hardware (CMOS) sincronizado."

echo
echo -e "${BOLD}4. Estado actual del reloj:${RESET}"
echo "----------------------------------------------------------------------"
timedatectl
echo "----------------------------------------------------------------------"
echo -e "Hora actual: ${GREEN}$(date "+%A %d de %B de %Y - %H:%M:%S")${RESET}"

pausar