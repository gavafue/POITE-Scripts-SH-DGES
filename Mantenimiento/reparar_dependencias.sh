#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Reparación general de dependencias, APT y paquetes del sistema
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🧱 REPARAR DEPENDENCIAS Y PAQUETES APT" "Resuelve bloqueos de dpkg, paquetes incompletos y dependencias rotas"

if ! asegurar_root; then
    exit 1
fi

echo -e "${CYAN}1. Desbloqueando y reconfigurando paquetes pendientes...${RESET}"
sudo dpkg --configure -a
imprimir_exito "dpkg verificado."

echo
echo -e "${CYAN}2. Reparando dependencias rotas en APT...${RESET}"
sudo apt-get --fix-broken install -y
sudo apt-get install -f -y
imprimir_exito "Dependencias de paquetes corregidas."

echo
echo -e "${CYAN}3. Actualizando índices de paquetes...${RESET}"
sudo apt-get update -y
imprimir_exito "Índices APT actualizados."

echo
echo -e "${CYAN}4. Limpiando paquetes obsoletos (autoremove) y caché descargada...${RESET}"
sudo apt-get autoremove --purge -y
sudo apt-get clean
sudo apt-get autoclean
imprimir_exito "Paquetes obsoletos y temporales eliminados."

echo
echo -e "${YELLOW}¿Desea realizar una actualización completa de software (upgrade)? (S/n): ${RESET}"
read -r respuesta
if [[ -z "$respuesta" || "$respuesta" =~ ^[sS]$ ]]; then
    echo -e "${CYAN}Aplicando actualizaciones...${RESET}"
    sudo apt-get upgrade -y
    imprimir_exito "Sistema actualizado con éxito."
fi

pausar