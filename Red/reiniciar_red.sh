#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Reinicio de servicios de red
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🔄 REINICIAR SERVICIOS DE RED" "Reinicia NetworkManager o systemd-networkd para restablecer conectividad"

if ! asegurar_root; then
    exit 1
fi

echo -e "${YELLOW}🔄 Reiniciando subsistema de red...${RESET}"

reinicio_ok=false

if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet NetworkManager 2>/dev/null || systemctl list-unit-files NetworkManager.service 2>/dev/null | grep -q NetworkManager; then
        echo -e "${CYAN}• Reiniciando NetworkManager...${RESET}"
        if sudo systemctl restart NetworkManager; then
            imprimir_exito "NetworkManager reiniciado correctamente."
            reinicio_ok=true
        fi
    fi

    if systemctl is-active --quiet networking 2>/dev/null || systemctl list-unit-files networking.service 2>/dev/null | grep -q networking; then
        echo -e "${CYAN}• Reiniciando servicio 'networking'...${RESET}"
        if sudo systemctl restart networking 2>/dev/null; then
            imprimir_exito "Servicio 'networking' reiniciado."
            reinicio_ok=true
        fi
    fi
fi

if [[ "$reinicio_ok" = false ]]; then
    imprimir_aviso "Intentando reactivar interfaz principal..."
    IFACE=$(obtener_interfaz_activa)
    sudo ip link set "$IFACE" down 2>/dev/null || true
    sleep 1
    sudo ip link set "$IFACE" up 2>/dev/null || true
    imprimir_exito "Interfaz $IFACE levantada."
fi

echo
echo -e "${BOLD}Estado actual de las interfaces de red:${RESET}"
ip -brief addr show 2>/dev/null || ip a

pausar