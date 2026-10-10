#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Archivo de funciones comunes y configuración global
# Autor: Prof. Gabriel Vázquez (INET / ANEP)
# ==============================================================================

# Determinar directorio raíz del proyecto de forma absoluta
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export BASE_DIR

# Directorio de datos de red (IPs y MACs)
DIR_DATOS="$BASE_DIR/RegistrarIP"
ARCHIVO_IPS="$DIR_DATOS/ips.txt"
ARCHIVO_MACS="$DIR_DATOS/macs.txt"
ARCHIVO_LOG="$DIR_DATOS/registro_ejecuciones.log"
SCRIPT_REMOTO="$DIR_DATOS/remoto.sh"

export DIR_DATOS ARCHIVO_IPS ARCHIVO_MACS ARCHIVO_LOG SCRIPT_REMOTO

# Asegurar existencia del directorio de datos
mkdir -p "$DIR_DATOS" 2>/dev/null || true

# Colores y formatos ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
RESET='\033[0m'

export RED GREEN BLUE CYAN YELLOW MAGENTA BOLD RESET

# Funciones de salida formateada
imprimir_encabezado() {
    local titulo="$1"
    local subtitulo="${2:-}"
    clear
    echo -e "${BLUE}======================================================================${RESET}"
    echo -e "${BOLD}${CYAN}   $titulo${RESET}"
    if [[ -n "$subtitulo" ]]; then
        echo -e "   ${YELLOW}$subtitulo${RESET}"
    fi
    echo -e "${BLUE}======================================================================${RESET}"
    echo
}

imprimir_exito() {
    echo -e "${GREEN}✅ $1${RESET}"
}

imprimir_error() {
    echo -e "${RED}❌ $1${RESET}"
}

imprimir_aviso() {
    echo -e "${YELLOW}⚠️  $1${RESET}"
}

imprimir_info() {
    echo -e "${CYAN}ℹ️  $1${RESET}"
}

pausar() {
    echo
    echo -ne "${MAGENTA}Presione ${BOLD}[Enter]${RESET}${MAGENTA} para continuar... ${RESET}"
    read -r
}

# Verificación y elevación segura de permisos de superusuario
asegurar_root() {
    if [[ $EUID -ne 0 ]]; then
        if command -v sudo >/dev/null 2>&1; then
            echo -e "${YELLOW}🔑 Esta acción requiere permisos de administrador. Ingrese su contraseña de sudo:${RESET}"
            if ! sudo -v; then
                imprimir_error "No se pudieron obtener privilegios de superusuario."
                pausar
                return 1
            fi
        else
            imprimir_error "Este script requiere ejecutarse como root y 'sudo' no está instalado."
            pausar
            return 1
        fi
    fi
    return 0
}

# Detección del sistema operativo
detectar_distro() {
    local distro="Desconocida"
    local version="N/A"
    local codename="focal"

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        distro="${NAME:-$distro}"
        version="${VERSION_ID:-$version}"
        codename="${VERSION_CODENAME:-${UBUNTU_CODENAME:-focal}}"
    elif command -v lsb_release >/dev/null 2>&1; then
        distro=$(lsb_release -ds)
        codename=$(lsb_release -cs)
    fi

    echo "$distro|$version|$codename"
}

# Obtener IP local primaria
obtener_ip_local() {
    local ip=""
    ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K[0-9.]+' || true)
    if [[ -z "$ip" ]]; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
    fi
    echo "${ip:-127.0.0.1}"
}

# Obtener interfaz activa
obtener_interfaz_activa() {
    local iface=""
    iface=$(ip route 2>/dev/null | awk '/default/ {print $5}' | head -n1 || true)
    if [[ -z "$iface" ]]; then
        iface=$(ip -o link show 2>/dev/null | awk -F': ' '$2 !~ /lo|vir/ {print $2}' | head -n1 || true)
    fi
    echo "${iface:-eth0}"
}
