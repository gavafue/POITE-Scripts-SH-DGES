#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Creación masiva de usuarios por lote (archivo CSV)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "👥 CREAR USUARIOS POR LOTES (CSV)" "Importación rápida de cuentas para grupos completos de estudiantes"

if ! asegurar_root; then
    exit 1
fi

echo -e "El archivo CSV debe tener el formato: ${BOLD}usuario,contraseña${RESET}"
echo -e "Ejemplo:\n  alumno01,Liceo2026\n  alumno02,Liceo2026\n"

read -e -p "📁 Ingrese la ruta del archivo CSV: " archivo

if [[ ! -f "$archivo" ]]; then
    imprimir_error "Archivo no encontrado: '$archivo'."
    pausar
    exit 1
fi

echo -e "${YELLOW}¿Desea crear un grupo secundario 'alumnos' para estos usuarios? (S/n): ${RESET}"
read -r crear_grp
if [[ -z "$crear_grp" || "$crear_grp" =~ ^[sS]$ ]]; then
    sudo groupadd alumnos 2>/dev/null || true
fi

echo
echo -e "${BOLD}Iniciando creación de cuentas...${RESET}"
echo "----------------------------------------------------------------------"

CREADOS=0
OMITIDOS=0

while IFS=, read -r usuario password || [[ -n "$usuario" ]]; do
    # Limpiar espacios y retornos de carro de Windows (\r)
    usuario=$(echo "$usuario" | tr -d '\r\n' | xargs)
    password=$(echo "$password" | tr -d '\r\n' | xargs)

    [[ -z "$usuario" || "$usuario" =~ ^# ]] && continue

    if id "$usuario" &>/dev/null; then
        echo -e "⏭️  Usuario ${YELLOW}'$usuario'${RESET} ya existe. Omitido."
        ((OMITIDOS++))
    else
        if sudo useradd -m -s /bin/bash -g alumnos "$usuario" 2>/dev/null || sudo useradd -m -s /bin/bash "$usuario"; then
            echo "$usuario:$password" | sudo chpasswd
            imprimir_exito "Usuario '$usuario' creado correctamente con shell /bin/bash."
            ((CREADOS++))
        else
            imprimir_error "No se pudo crear el usuario '$usuario'."
        fi
    fi
done < "$archivo"

echo "----------------------------------------------------------------------"
echo -e "${BOLD}Resumen:${RESET} Creados: ${GREEN}$CREADOS${RESET} | Omitidos: ${YELLOW}$OMITIDOS${RESET}"
pausar