#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador del comando global 'poite' en el sistema
# ==============================================================================

# Resolver ruta canónica del proyecto
_FUENTE_CANONICA="${BASH_SOURCE[0]}"
while [[ -h "$_FUENTE_CANONICA" ]]; do
    _DIR_TEMP="$(cd -P "$(dirname "$_FUENTE_CANONICA")" && pwd)"
    _FUENTE_CANONICA="$(readlink "$_FUENTE_CANONICA")"
    [[ "$_FUENTE_CANONICA" != /* ]] && _FUENTE_CANONICA="$_DIR_TEMP/$_FUENTE_CANONICA"
done
SCRIPT_DIR="$(cd -P "$(dirname "$_FUENTE_CANONICA")" && pwd)"

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
echo -e "${CYAN}2. Creando lanzador ejecutable en /usr/local/bin/poite...${RESET}"
sudo mkdir -p /usr/local/bin
sudo tee /usr/local/bin/poite > /dev/null <<EOF
#!/bin/bash
exec "$SCRIPT_DIR/menu.sh" "\$@"
EOF
sudo chmod +x /usr/local/bin/poite
sudo ln -sf /usr/local/bin/poite /usr/local/bin/asistente-poite

if command -v poite >/dev/null 2>&1; then
    imprimir_exito "¡Instalación completada con éxito!"
    echo
    echo -e "${BOLD}${GREEN}A partir de ahora puedes abrir el asistente en cualquier terminal ejecutando:${RESET}"
    echo -e "   ${BOLD}${YELLOW}poite${RESET}"
else
    imprimir_aviso "Se creó el lanzador en /usr/local/bin/poite. Verifique que /usr/local/bin forme parte de su variable \$PATH."
fi

pausar
