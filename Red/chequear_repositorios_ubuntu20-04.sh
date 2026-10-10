#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Verificar y restaurar repositorios oficiales APT
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📦 VERIFICAR REPOSITORIOS OFICIALES APT" "Garantiza acceso a paquetes base (main, restricted, universe, multiverse)"

INFO_DISTRO=$(detectar_distro)
CODENAME=$(echo "$INFO_DISTRO" | cut -d'|' -f3)

# Fallback si no se detecta
CODENAME="${CODENAME:-focal}"

echo -e "Distribución detectada: ${BOLD}${CYAN}$INFO_DISTRO${RESET}"
echo -e "Nombre clave de versión: ${BOLD}${GREEN}$CODENAME${RESET}"
echo

if ! asegurar_root; then
    exit 1
fi

SOURCES_LIST="/etc/apt/sources.list"
BACKUP_FILE="/etc/apt/sources.list.bak-$(date +%Y%m%d%H%M%S)"

echo -e "🔒 Creando copia de respaldo en: ${CYAN}$BACKUP_FILE${RESET}"
sudo cp "$SOURCES_LIST" "$BACKUP_FILE"

REPOS=(
  "deb http://archive.ubuntu.com/ubuntu/ $CODENAME main restricted universe multiverse"
  "deb http://archive.ubuntu.com/ubuntu/ ${CODENAME}-updates main restricted universe multiverse"
  "deb http://archive.ubuntu.com/ubuntu/ ${CODENAME}-security main restricted universe multiverse"
  "deb http://archive.ubuntu.com/ubuntu/ ${CODENAME}-backports main restricted universe multiverse"
)

echo
echo -e "${BOLD}Comprobando repositorios oficiales para '$CODENAME':${RESET}"
for repo in "${REPOS[@]}"; do
    if grep -qE "^\s*deb\s+.*$CODENAME" "$SOURCES_LIST" 2>/dev/null; then
        echo -e "✔️ Rama presente: ${CYAN}$repo${RESET}"
    else
        echo -e "➕ Agregando: ${YELLOW}$repo${RESET}"
        echo "$repo" | sudo tee -a "$SOURCES_LIST" > /dev/null
    fi
done

echo
echo -e "${YELLOW}¿Desea actualizar la lista de paquetes ahora (apt update)? (S/n): ${RESET}"
read -r resp
if [[ -z "$resp" || "$resp" =~ ^[sS]$ ]]; then
    sudo apt update
fi

imprimir_exito "Verificación de repositorios completada."
pausar