#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Verificar y restaurar repositorios oficiales del sistema operativo
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📦 VERIFICAR REPOSITORIOS OFICIALES" "Comprueba la integridad de fuentes de software para '$DISTRO_NAME'"

echo -e "Distribución detectada: ${BOLD}${CYAN}$DISTRO_NAME${RESET}"
echo -e "Familia: ${BOLD}${GREEN}$DISTRO_FAMILY${RESET} | Gestor: ${BOLD}${MAGENTA}$PKG_MANAGER${RESET}"
echo -e "Codename: ${BOLD}${YELLOW}$DISTRO_CODENAME${RESET}"
echo

if ! asegurar_root; then
    exit 1
fi

case "$DISTRO_FAMILY" in
    debian)
        SOURCES_LIST="/etc/apt/sources.list"
        BACKUP_FILE="/etc/apt/sources.list.bak-$(date +%Y%m%d%H%M%S)"

        if [[ -f "$SOURCES_LIST" ]]; then
            echo -e "🔒 Creando copia de respaldo en: ${CYAN}$BACKUP_FILE${RESET}"
            sudo cp "$SOURCES_LIST" "$BACKUP_FILE"

            CODENAME="${DISTRO_CODENAME:-focal}"
            [[ "$CODENAME" == "rolling" ]] && CODENAME="focal"

            echo
            echo -e "${BOLD}Comprobando repositorios oficiales para '$CODENAME':${RESET}"
            REPOS=(
              "deb http://archive.ubuntu.com/ubuntu/ $CODENAME main restricted universe multiverse"
              "deb http://archive.ubuntu.com/ubuntu/ ${CODENAME}-updates main restricted universe multiverse"
              "deb http://archive.ubuntu.com/ubuntu/ ${CODENAME}-security main restricted universe multiverse"
            )
            for repo in "${REPOS[@]}"; do
                if grep -qE "^\s*deb\s+.*$CODENAME" "$SOURCES_LIST" 2>/dev/null; then
                    echo -e "✔️ Rama presente: ${CYAN}$repo${RESET}"
                else
                    echo -e "➕ Agregando: ${YELLOW}$repo${RESET}"
                    echo "$repo" | sudo tee -a "$SOURCES_LIST" > /dev/null
                fi
            done
        else
            imprimir_info "Sistema Debian/Ubuntu utilizando formato moderno deb822 en /etc/apt/sources.list.d/."
        fi
        ;;

    redhat)
        echo -e "${BOLD}Comprobando repositorios activos en DNF/YUM:${RESET}"
        sudo "$PKG_MANAGER" repolist
        echo
        imprimir_exito "Repositorios de la familia Red Hat / Fedora verificados."
        ;;

    arch)
        echo -e "${BOLD}Comprobando configuración de repositorios en Pacman:${RESET}"
        grep -E "^\[(core|extra|multilib)\]" /etc/pacman.conf 2>/dev/null || true
        echo
        imprimir_exito "Configuración de repositorios de Arch Linux verificada."
        ;;

    suse)
        echo -e "${BOLD}Comprobando repositorios en Zypper:${RESET}"
        sudo zypper lr
        echo
        imprimir_exito "Repositorios de openSUSE verificados."
        ;;

    *)
        imprimir_aviso "Distribución genérica: no se dispone de plantilla específica."
        ;;
esac

echo
echo -e "${YELLOW}¿Desea actualizar los índices de paquetes ahora? (S/n): ${RESET}"
read -r resp
if [[ -z "$resp" || "$resp" =~ ^[sS]$ ]]; then
    actualizar_repositorios
fi

imprimir_exito "Verificación de repositorios completada."
pausar
