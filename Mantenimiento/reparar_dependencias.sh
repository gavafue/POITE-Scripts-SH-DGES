#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Reparación general de dependencias, paquetes e índices del sistema
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🧱 REPARAR DEPENDENCIAS Y PAQUETES" "Corrige inconsistencias en el gestor de paquetes ($PKG_MANAGER - $DISTRO_FAMILY)"

if ! asegurar_root; then
    exit 1
fi

reparar_paquetes
echo
limpiar_paquetes

echo
echo -e "${YELLOW}¿Desea realizar una actualización completa de software del sistema? (S/n): ${RESET}"
read -r respuesta
if [[ -z "$respuesta" || "$respuesta" =~ ^[sS]$ ]]; then
    actualizar_sistema
    imprimir_exito "Sistema actualizado con éxito."
fi

pausar