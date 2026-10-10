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
echo -e "${YELLOW}¿El usuario debe tener permisos de administrador ($GRUPO_ADMIN)?${RESET}"
echo "  [s] Sí (para docentes / administradores)"
echo "  [n] No (recomendado para estudiantes / invitados)"
read -p "Seleccione [s/N]: " es_admin

creado=false

if [[ "$DISTRO_FAMILY" == "debian" ]] && command -v adduser >/dev/null 2>&1; then
    if sudo adduser --gecos "" "$user"; then
        creado=true
    fi
else
    # Red Hat / Fedora / Arch / SUSE (usar useradd estándar)
    if sudo useradd -m -s /bin/bash "$user"; then
        echo -e "${CYAN}Establezca la contraseña para el usuario '$user':${RESET}"
        sudo passwd "$user"
        creado=true
    fi
fi

if [[ "$creado" = true ]]; then
    if [[ "$es_admin" =~ ^[sS]$ ]]; then
        sudo usermod -aG "$GRUPO_ADMIN" "$user"
        imprimir_exito "Usuario '$user' creado CON permisos de administrador (grupo $GRUPO_ADMIN)."
    else
        imprimir_exito "Usuario estándar '$user' creado (sin privilegios de administrador)."
    fi
else
    imprimir_error "Ocurrió un error al crear el usuario '$user'."
fi

pausar