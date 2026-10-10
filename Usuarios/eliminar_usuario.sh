#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Eliminación segura de cuentas de usuario
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "➖ ELIMINAR USUARIO DEL SISTEMA" "Eliminación controlada de cuentas con salvaguarda de seguridad"

if ! asegurar_root; then
    exit 1
fi

echo -e "${BOLD}Cuentas de usuario registradas en el sistema:${RESET}"
cut -d: -f1,3 /etc/passwd | awk -F: '$2 >= 1000 && $2 < 60000 {print "  • " $1}'
echo

read -p "👤 Ingrese el nombre del usuario a eliminar: " usuario

if [[ "$usuario" == "root" || "$usuario" == "$(whoami)" ]]; then
    imprimir_error "Por seguridad no es posible eliminar la cuenta 'root' ni la cuenta actualmente en uso."
    pausar
    exit 1
fi

if ! id "$usuario" &>/dev/null; then
    imprimir_error "El usuario '$usuario' no existe."
    pausar
    exit 1
fi

# Cerrar procesos activos del usuario si los hubiera
sudo pkill -u "$usuario" 2>/dev/null || true

read -p "¿Desea eliminar también su carpeta personal /home/$usuario? (s/N): " respuesta

if [[ "$respuesta" =~ ^[sS]$ ]]; then
    sudo deluser --remove-home "$usuario" 2>/dev/null || sudo userdel -r "$usuario"
    imprimir_exito "Usuario '$usuario' y su carpeta personal eliminados."
else
    sudo deluser "$usuario" 2>/dev/null || sudo userdel "$usuario"
    imprimir_exito "Usuario '$usuario' eliminado (conservando archivos en /home)."
fi

pausar