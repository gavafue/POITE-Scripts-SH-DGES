#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador del comando global 'poite' en el sistema
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🚀 INSTALADOR DEL COMANDO GLOBAL 'poite'" "Permite abrir el asistente desde cualquier terminal simplemente escribiendo 'poite'"

if ! asegurar_root; then
    exit 1
fi

echo -e "${CYAN}1. Otorgando permisos de ejecución a todos los scripts...${RESET}"
chmod +x "$SCRIPT_DIR/menu.sh"
find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} +
imprimir_exito "Permisos configurados."

echo
echo -e "${CYAN}2. Creando enlace en /usr/local/bin/poite...${RESET}"
sudo ln -sf "$SCRIPT_DIR/menu.sh" /usr/local/bin/poite
sudo ln -sf "$SCRIPT_DIR/menu.sh" /usr/local/bin/asistente-poite

if command -v poite >/dev/null 2>&1; then
    imprimir_exito "¡Instalación completada con éxito!"
    echo
    echo -e "${BOLD}${GREEN}A partir de ahora puedes abrir el asistente en cualquier terminal ejecutando:${RESET}"
    echo -e "   ${BOLD}${YELLOW}poite${RESET}"
else
    imprimir_aviso "Se creó el enlace en /usr/local/bin/poite. Asegúrate de que /usr/local/bin esté en tu \$PATH."
fi

pausar
