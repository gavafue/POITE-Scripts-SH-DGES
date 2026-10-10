#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalación y habilitación del servicio OpenSSH Server
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🔐 SERVIDOR SSH (OPENSSH SERVER)" "Habilita acceso remoto seguro para administración del aula"

if ! asegurar_root; then
    exit 1
fi

SERVICIO_SSH=$(servicio_nombre "ssh")

echo -e "${CYAN}Detectando paquetes para la familia '${DISTRO_FAMILY}'...${RESET}"
PAQUETE_SSH="openssh-server"
if [[ "$DISTRO_FAMILY" == "arch" || "$DISTRO_FAMILY" == "suse" ]]; then
    PAQUETE_SSH="openssh"
fi

echo -e "${CYAN}Instalando y activando servicio OpenSSH ($PAQUETE_SSH)...${RESET}"
actualizar_repositorios
instalar_paquetes "$PAQUETE_SSH"

sudo systemctl enable "$SERVICIO_SSH" 2>/dev/null || true
sudo systemctl restart "$SERVICIO_SSH" 2>/dev/null || true

if systemctl is-active --quiet "$SERVICIO_SSH"; then
    IP_ACTUAL=$(obtener_ip_local)
    USUARIO_ACTUAL=$(whoami)
    imprimir_exito "Servidor SSH activo y escuchando en el puerto 22 (servicio: $SERVICIO_SSH)."
    echo
    echo -e "${BOLD}Para conectarse desde otra máquina del aula ejecute:${RESET}"
    echo -e "  ${GREEN}ssh ${USUARIO_ACTUAL}@${IP_ACTUAL}${RESET}"
else
    imprimir_error "No se pudo iniciar el servicio SSH ($SERVICIO_SSH)."
fi

pausar