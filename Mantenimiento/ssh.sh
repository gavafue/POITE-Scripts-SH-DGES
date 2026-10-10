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

echo -e "${CYAN}Instalando y activando servicio OpenSSH...${RESET}"
sudo apt update && sudo apt install -y openssh-server

sudo systemctl enable ssh
sudo systemctl restart ssh

if systemctl is-active --quiet ssh; then
    IP_ACTUAL=$(obtener_ip_local)
    USUARIO_ACTUAL=$(whoami)
    imprimir_exito "Servidor SSH activo y escuchando en el puerto 22."
    echo
    echo -e "${BOLD}Para conectarse desde otra máquina del aula ejecute:${RESET}"
    echo -e "  ${GREEN}ssh ${USUARIO_ACTUAL}@${IP_ACTUAL}${RESET}"
else
    imprimir_error "No se pudo iniciar el servicio SSH."
fi

pausar