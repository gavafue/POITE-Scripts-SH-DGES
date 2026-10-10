#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Restablecimiento de contraseña de usuario
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🔑 RESTABLECER CONTRASEÑA DE USUARIO" "Cambio forzado de clave para alumnos o docentes que olvidaron su acceso"

if ! asegurar_root; then
    exit 1
fi

echo -e "${BOLD}Usuarios locales en el equipo:${RESET}"
cut -d: -f1,3 /etc/passwd | awk -F: '$2 >= 1000 && $2 < 60000 {print "  • " $1}'
echo

read -p "👤 Ingrese el nombre del usuario: " usuario

if ! id "$usuario" &>/dev/null; then
    imprimir_error "El usuario '$usuario' no existe."
    pausar
    exit 1
fi

echo -e "${CYAN}Introduzca la nueva contraseña para '$usuario':${RESET}"
if sudo passwd "$usuario"; then
    imprimir_exito "La contraseña de '$usuario' fue actualizada correctamente."
else
    imprimir_error "No se pudo actualizar la contraseña."
fi

pausar