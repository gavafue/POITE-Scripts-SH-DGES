#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador de Suite de Software Educativo multi-distribución
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📚 SUITE DE SOFTWARE EDUCATIVO (DGES / URUGUAY)" "Herramientas pedagógicas, ofimática, ciencias, programación y multimedia"

if ! asegurar_root; then
    exit 1
fi

mapear_paquete_distro() {
    local pkg="$1"
    case "$pkg" in
        libreoffice-l10n-es)
            case "$DISTRO_FAMILY" in
                redhat) echo "libreoffice-langpack-es" ;;
                arch)   echo "libreoffice-fresh-es" ;;
                *)      echo "libreoffice-l10n-es" ;;
            esac
            ;;
        gufw)
            case "$DISTRO_FAMILY" in
                redhat) echo "firewalld" ;;
                *)      echo "gufw" ;;
            esac
            ;;
        *)
            echo "$pkg"
            ;;
    esac
}

instalar_lista() {
    local nombre_categoria="$1"
    shift
    local paquetes=("$@")

    echo -e "${BOLD}${CYAN}Instalando categoría: $nombre_categoria (${PKG_MANAGER})...${RESET}"
    echo "----------------------------------------------------------------------"

    local para_instalar=()
    for pkg in "${paquetes[@]}"; do
        local pkg_real
        pkg_real=$(mapear_paquete_distro "$pkg")

        if paquete_instalado "$pkg_real"; then
            echo -e "✔️ Ya instalado: ${GREEN}$pkg_real${RESET}"
        elif paquete_disponible "$pkg_real"; then
            para_instalar+=("$pkg_real")
        else
            echo -e "⚠️  No disponible en repositorios oficiales: ${YELLOW}$pkg_real${RESET}"
        fi
    done

    if [ ${#para_instalar[@]} -gt 0 ]; then
        echo -e "${YELLOW}Instalando paquetes pendientes: ${para_instalar[*]}...${RESET}"
        instalar_paquetes "${para_instalar[@]}" || true
    else
        imprimir_exito "Todos los paquetes disponibles de esta categoría ya están al día."
    fi
    echo
}

PKGS_OFIMATICA=(libreoffice libreoffice-l10n-es pdfarranger vlc keepassxc bleachbit timeshift gparted gufw)
PKGS_DEV=(thonny geany kate scratch)
PKGS_CIENCIAS=(gcompris-qt kalzium kstars stellarium tuxmath tuxtype)
PKGS_DISENO=(gimp inkscape krita tuxpaint audacity obs-studio kdenlive)

echo -e "Distribución detectada: ${BOLD}${CYAN}${DISTRO_NAME}${RESET} (${DISTRO_FAMILY} / ${PKG_MANAGER})"
echo
echo -e "Seleccione qué componentes desea instalar en este equipo:"
echo -e "  ${GREEN}1)${RESET} 🌟 ${BOLD}Suite Educativa COMPLETA${RESET} (Todas las aplicaciones escolares)"
echo -e "  ${GREEN}2)${RESET} 📝 Ofimática, Visores y Utilidades (LibreOffice, PDF, VLC, Seguridad)"
echo -e "  ${GREEN}3)${RESET} 💻 Programación y Robótica (Thonny, Geany, Kate, Scratch)"
echo -e "  ${GREEN}4)${RESET} 🔬 Ciencias, Astronomía y Matemáticas (Stellarium, GCompris, Kalzium)"
echo -e "  ${GREEN}5)${RESET} 🎨 Arte, Diseño, Edición Gráfica y Video (GIMP, Inkscape, Krita, Audacity)"
echo -e "  ${RED}0)${RESET} 🔙 Cancelar y volver"
echo
echo -ne "${BOLD}Seleccione una opción [0-5]: ${RESET}"
read -r opcion

case "$opcion" in
    1)
        actualizar_repositorios
        instalar_lista "Ofimática y Utilidades" "${PKGS_OFIMATICA[@]}"
        instalar_lista "Programación y Robótica" "${PKGS_DEV[@]}"
        instalar_lista "Ciencias y Matemáticas" "${PKGS_CIENCIAS[@]}"
        instalar_lista "Arte y Multimedia" "${PKGS_DISENO[@]}"
        imprimir_exito "Instalación de la Suite Educativa Completa finalizada."
        ;;
    2)
        actualizar_repositorios
        instalar_lista "Ofimática y Utilidades" "${PKGS_OFIMATICA[@]}"
        ;;
    3)
        actualizar_repositorios
        instalar_lista "Programación y Robótica" "${PKGS_DEV[@]}"
        ;;
    4)
        actualizar_repositorios
        instalar_lista "Ciencias y Matemáticas" "${PKGS_CIENCIAS[@]}"
        ;;
    5)
        actualizar_repositorios
        instalar_lista "Arte y Multimedia" "${PKGS_DISENO[@]}"
        ;;
    0)
        imprimir_info "Operación cancelada."
        ;;
    *)
        imprimir_error "Opción no válida."
        ;;
esac

pausar