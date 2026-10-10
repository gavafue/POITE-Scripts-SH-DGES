#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Creación de usuario individual con control de privilegios de aula
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "👥 CREAR NUEVO USUARIO" "Configuración de cuentas para alumnos, docentes o administración"

if ! asegurar_root; then
    exit 1
fi

read -p "👤 Ingrese el nombre de usuario (ej: alumno / grupo1 / profe): " user

# Validar formato de nombre de usuario Unix
if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    imprimir_error "El nombre de usuario solo debe contener letras minúsculas, números y guiones."
    pausar
    exit 1
fi

if id "$user" &>/dev/null; then
    imprimir_aviso "El usuario '$user' ya existe en este sistema."
    pausar
    exit 0
fi

echo
echo -e "${YELLOW}¿El usuario debe tener permisos de administrador (sudo)?${RESET}"
echo "  [s] Sí (para docentes / administradores)"
echo "  [n] No (recomendado para estudiantes / invitados)"
read -p "Seleccione [s/N]: " es_admin

if sudo adduser --gecos "" "$user"; then
    if [[ "$es_admin" =~ ^[sS]$ ]]; then
        sudo usermod -aG sudo "$user" 2>/dev/null || sudo usermod -aG wheel "$user" 2>/dev/null
        imprimir_exito "Usuario '$user' creado CON permisos de administrador (sudo)."
    else
        imprimir_exito "Usuario estándar '$user' creado (sin privilegios de root)."
    fi
else
    imprimir_error "Ocurrió un error al crear el usuario '$user'."
fi

pausar