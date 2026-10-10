#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Archivo de funciones comunes y configuración global
# Autor: Prof. Gabriel Vázquez (INET / ANEP)
# ==============================================================================

# Determinar directorio raíz del proyecto de forma canónica y absoluta
# (Soporta symlinks como /usr/local/bin/poite)
_FUENTE_CANONICA="${BASH_SOURCE[0]}"
while [[ -h "$_FUENTE_CANONICA" ]]; do
    _DIR_TEMP="$(cd -P "$(dirname "$_FUENTE_CANONICA")" && pwd)"
    _FUENTE_CANONICA="$(readlink "$_FUENTE_CANONICA")"
    [[ "$_FUENTE_CANONICA" != /* ]] && _FUENTE_CANONICA="$_DIR_TEMP/$_FUENTE_CANONICA"
done
BASE_DIR="$(cd -P "$(dirname "$_FUENTE_CANONICA")/.." && pwd)"
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

# ==============================================================================
# FUNCIONES DE SALIDA FORMATEADA
# ==============================================================================

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

# ==============================================================================
# SEGURIDAD Y PRIVILEGIOS
# ==============================================================================

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
            imprimir_error "Este script requiere ejecutarse como root y 'sudo' no está disponible."
            pausar
            return 1
        fi
    fi
    return 0
}

# ==============================================================================
# MOTOR DE DETECCIÓN MULTI-DISTRIBUCIÓN
# ==============================================================================

detectar_sistema_completo() {
    DISTRO_NAME="GNU/Linux"
    DISTRO_ID="desconocido"
    DISTRO_ID_LIKE=""
    DISTRO_VERSION="N/A"
    DISTRO_CODENAME="rolling"
    DISTRO_FAMILY="generica"
    PKG_MANAGER="desconocido"
    DISTRO_ARCH="$(uname -m)"

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        DISTRO_NAME="${PRETTY_NAME:-${NAME:-GNU/Linux}}"
        DISTRO_ID="${ID:-desconocido}"
        DISTRO_ID_LIKE="${ID_LIKE:-}"
        DISTRO_VERSION="${VERSION_ID:-${VERSION:-N/A}}"
        DISTRO_CODENAME="${VERSION_CODENAME:-${UBUNTU_CODENAME:-rolling}}"
    elif command -v lsb_release >/dev/null 2>&1; then
        DISTRO_NAME="$(lsb_release -ds 2>/dev/null)"
        DISTRO_ID="$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')"
        DISTRO_VERSION="$(lsb_release -rs 2>/dev/null)"
        DISTRO_CODENAME="$(lsb_release -cs 2>/dev/null)"
    fi

    # Normalizar codename si quedó vacío
    if [[ -z "$DISTRO_CODENAME" ]]; then
        DISTRO_CODENAME="rolling"
    fi

    # Determinar familia de la distribución
    case "$DISTRO_ID" in
        fedora|rhel|centos|rocky|almalinux|ol|amzn)
            DISTRO_FAMILY="redhat"
            ;;
        debian|ubuntu|linuxmint|pop|elementary|zorin|kali|raspbian|pureos|parrot)
            DISTRO_FAMILY="debian"
            ;;
        arch|manjaro|endeavouros|garuda|arco)
            DISTRO_FAMILY="arch"
            ;;
        opensuse*|sles|suse)
            DISTRO_FAMILY="suse"
            ;;
        *)
            if [[ "$DISTRO_ID_LIKE" =~ (debian|ubuntu) ]]; then
                DISTRO_FAMILY="debian"
            elif [[ "$DISTRO_ID_LIKE" =~ (rhel|fedora|centos) ]]; then
                DISTRO_FAMILY="redhat"
            elif [[ "$DISTRO_ID_LIKE" =~ (arch) ]]; then
                DISTRO_FAMILY="arch"
            elif [[ "$DISTRO_ID_LIKE" =~ (suse) ]]; then
                DISTRO_FAMILY="suse"
            else
                if command -v apt-get >/dev/null 2>&1 || command -v apt >/dev/null 2>&1; then
                    DISTRO_FAMILY="debian"
                elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
                    DISTRO_FAMILY="redhat"
                elif command -v pacman >/dev/null 2>&1; then
                    DISTRO_FAMILY="arch"
                elif command -v zypper >/dev/null 2>&1; then
                    DISTRO_FAMILY="suse"
                else
                    DISTRO_FAMILY="generica"
                fi
            fi
            ;;
    esac

    # Determinar gestor de paquetes principal
    if command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
    elif command -v apt-get >/dev/null 2>&1 || command -v apt >/dev/null 2>&1; then
        PKG_MANAGER="apt"
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
    elif command -v zypper >/dev/null 2>&1; then
        PKG_MANAGER="zypper"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MANAGER="yum"
    else
        PKG_MANAGER="desconocido"
    fi

    # Determinar grupo de administración (sudo en Debian/Ubuntu vs wheel en RedHat/Arch)
    if getent group sudo >/dev/null 2>&1; then
        GRUPO_ADMIN="sudo"
    elif getent group wheel >/dev/null 2>&1; then
        GRUPO_ADMIN="wheel"
    else
        GRUPO_ADMIN="root"
    fi

    export DISTRO_NAME DISTRO_ID DISTRO_ID_LIKE DISTRO_VERSION DISTRO_CODENAME DISTRO_FAMILY PKG_MANAGER DISTRO_ARCH GRUPO_ADMIN
}

# Ejecutar detección inmediatamente al cargar la librería
detectar_sistema_completo

# Función de compatibilidad regresiva
detectar_distro() {
    echo "${DISTRO_NAME}|${DISTRO_VERSION}|${DISTRO_CODENAME}"
}

# Visualizador del entorno
imprimir_resumen_distro() {
    echo -e "${BOLD}🐧 Entorno GNU/Linux Detectado:${RESET}"
    echo -e "   • Distribución:     ${BOLD}${CYAN}${DISTRO_NAME}${RESET}"
    echo -e "   • Familia:          ${GREEN}${DISTRO_FAMILY}${RESET} (ID: ${DISTRO_ID})"
    echo -e "   • Versión/Codename: ${YELLOW}${DISTRO_VERSION}${RESET} (${DISTRO_CODENAME})"
    echo -e "   • Gestor Paquetes:  ${MAGENTA}${PKG_MANAGER}${RESET}"
    echo -e "   • Arquitectura:     ${BLUE}${DISTRO_ARCH}${RESET}"
    echo -e "   • Grupo Admin:      ${CYAN}${GRUPO_ADMIN}${RESET}"
}

# ==============================================================================
# CAPA DE ABSTRACCIÓN DE GESTIÓN DE PAQUETES
# ==============================================================================

actualizar_repositorios() {
    asegurar_root || return 1
    echo -e "${CYAN}🔄 Actualizando listas de paquetes (${PKG_MANAGER})...${RESET}"
    case "$PKG_MANAGER" in
        apt)
            sudo apt-get update -y
            ;;
        dnf|yum)
            # dnf devuelve 100 si hay actualizaciones listas para instalar
            sudo "$PKG_MANAGER" check-update -y || [[ $? -eq 100 ]]
            ;;
        pacman)
            sudo pacman -Sy --noconfirm
            ;;
        zypper)
            sudo zypper refresh
            ;;
        *)
            imprimir_error "Gestor de paquetes no soportado para actualizar repositorios ($PKG_MANAGER)."
            return 1
            ;;
    esac
}

actualizar_sistema() {
    asegurar_root || return 1
    echo -e "${CYAN}📦 Actualizando software del sistema completo (${PKG_MANAGER})...${RESET}"
    case "$PKG_MANAGER" in
        apt)
            sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
            ;;
        dnf|yum)
            sudo "$PKG_MANAGER" upgrade -y
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            ;;
        zypper)
            sudo zypper update -y
            ;;
        *)
            imprimir_error "Gestor no soportado para actualización total."
            return 1
            ;;
    esac
}

instalar_paquetes() {
    asegurar_root || return 1
    if [[ $# -eq 0 ]]; then
        return 0
    fi
    echo -e "${CYAN}📥 Instalando: $* (${PKG_MANAGER})...${RESET}"
    case "$PKG_MANAGER" in
        apt)
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
            ;;
        dnf|yum)
            sudo "$PKG_MANAGER" install -y "$@"
            ;;
        pacman)
            sudo pacman -S --noconfirm --needed "$@"
            ;;
        zypper)
            sudo zypper install -y "$@"
            ;;
        *)
            imprimir_error "No se puede instalar en este entorno ($PKG_MANAGER)."
            return 1
            ;;
    esac
}

remover_paquetes() {
    asegurar_root || return 1
    if [[ $# -eq 0 ]]; then
        return 0
    fi
    echo -e "${YELLOW}🗑️  Desinstalando: $* (${PKG_MANAGER})...${RESET}"
    case "$PKG_MANAGER" in
        apt)
            sudo apt-get remove -y "$@"
            ;;
        dnf|yum)
            sudo "$PKG_MANAGER" remove -y "$@"
            ;;
        pacman)
            sudo pacman -R --noconfirm "$@"
            ;;
        zypper)
            sudo zypper remove -y "$@"
            ;;
        *)
            imprimir_error "Gestor de paquetes no reconocido ($PKG_MANAGER)."
            return 1
            ;;
    esac
}

limpiar_paquetes() {
    asegurar_root || return 1
    echo -e "${CYAN}🧹 Limpiando archivos temporales y paquetes huérfanos (${PKG_MANAGER})...${RESET}"
    case "$PKG_MANAGER" in
        apt)
            sudo apt-get autoremove --purge -y
            sudo apt-get clean
            sudo apt-get autoclean
            ;;
        dnf|yum)
            sudo "$PKG_MANAGER" autoremove -y
            sudo "$PKG_MANAGER" clean all
            ;;
        pacman)
            sudo pacman -Sc --noconfirm
            ;;
        zypper)
            sudo zypper clean -a
            ;;
    esac
    imprimir_exito "Caché de paquetes y dependencias obsoletas liberadas."
}

reparar_paquetes() {
    asegurar_root || return 1
    echo -e "${CYAN}🧱 Iniciando proceso de reparación para familia '$DISTRO_FAMILY' ($PKG_MANAGER)...${RESET}"
    case "$DISTRO_FAMILY" in
        debian)
            echo -e "${CYAN}1. Desbloqueando y reconfigurando paquetes pendientes (dpkg)...${RESET}"
            sudo dpkg --configure -a
            echo -e "${CYAN}2. Reparando dependencias rotas en APT...${RESET}"
            sudo apt-get --fix-broken install -y
            sudo apt-get install -f -y
            ;;
        redhat)
            echo -e "${CYAN}1. Verificando base de datos RPM...${RESET}"
            sudo rpm --rebuilddb
            echo -e "${CYAN}2. Comprobando problemas de dependencias en $PKG_MANAGER...${RESET}"
            sudo "$PKG_MANAGER" check || true
            echo -e "${CYAN}3. Sincronizando paquetes con repositorios oficiales...${RESET}"
            sudo "$PKG_MANAGER" distro-sync -y || true
            ;;
        arch)
            echo -e "${CYAN}1. Actualizando llaves de firma del keyring...${RESET}"
            sudo pacman-key --init 2>/dev/null || true
            sudo pacman-key --populate 2>/dev/null || true
            sudo pacman -Sy --noconfirm archlinux-keyring 2>/dev/null || true
            ;;
        suse)
            echo -e "${CYAN}1. Verificando dependencias con zypper...${RESET}"
            sudo zypper verify -y
            ;;
        *)
            imprimir_aviso "Distribución genérica: no hay rutina de reparación específica."
            ;;
    esac
    imprimir_exito "Reparación de paquetes completada."
}

paquete_instalado() {
    local pkg="$1"
    case "$DISTRO_FAMILY" in
        debian)
            dpkg -s "$pkg" >/dev/null 2>&1
            ;;
        redhat|suse)
            rpm -q "$pkg" >/dev/null 2>&1
            ;;
        arch)
            pacman -Q "$pkg" >/dev/null 2>&1
            ;;
        *)
            command -v "$pkg" >/dev/null 2>&1
            ;;
    esac
}

paquete_disponible() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        apt)
            apt-cache show "$pkg" >/dev/null 2>&1
            ;;
        dnf|yum)
            "$PKG_MANAGER" info "$pkg" >/dev/null 2>&1
            ;;
        pacman)
            pacman -Si "$pkg" >/dev/null 2>&1
            ;;
        zypper)
            zypper info "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# ==============================================================================
# GESTIÓN DE SERVICIOS SYSTEMD / SYSTEM
# ==============================================================================

servicio_nombre() {
    local canonico="$1"
    case "$canonico" in
        ssh)
            if [[ "$DISTRO_FAMILY" == "debian" ]]; then
                echo "ssh"
            else
                echo "sshd"
            fi
            ;;
        cron)
            if [[ "$DISTRO_FAMILY" == "debian" ]]; then
                echo "cron"
            else
                echo "crond"
            fi
            ;;
        ntp|timesync)
            if systemctl list-unit-files 2>/dev/null | grep -q chronyd.service; then
                echo "chronyd"
            elif systemctl list-unit-files 2>/dev/null | grep -q systemd-timesyncd.service; then
                echo "systemd-timesyncd"
            else
                echo "chronyd"
            fi
            ;;
        network|red)
            echo "NetworkManager"
            ;;
        *)
            echo "$canonico"
            ;;
    esac
}

servicio_gestionar() {
    local accion="$1"
    local canonico="$2"
    local srv
    srv=$(servicio_nombre "$canonico")

    if command -v systemctl >/dev/null 2>&1; then
        case "$accion" in
            is-active)
                systemctl is-active --quiet "$srv"
                return $?
                ;;
            status)
                systemctl status "$srv"
                return $?
                ;;
            start|stop|restart|reload|enable|disable)
                asegurar_root || return 1
                sudo systemctl "$accion" "$srv"
                return $?
                ;;
            *)
                imprimir_error "Acción no válida: $accion"
                return 1
                ;;
        esac
    elif command -v service >/dev/null 2>&1; then
        asegurar_root || return 1
        sudo service "$srv" "$accion"
    else
        imprimir_error "Sistema de inicio no compatible (ni systemctl ni service)."
        return 1
    fi
}

# ==============================================================================
# UTILIDADES DE RED Y ENTORNO
# ==============================================================================

obtener_ip_local() {
    local ip=""
    ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K[0-9.]+' || true)
    if [[ -z "$ip" ]]; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
    fi
    echo "${ip:-127.0.0.1}"
}

obtener_interfaz_activa() {
    local iface=""
    iface=$(ip route 2>/dev/null | awk '/default/ {print $5}' | head -n1 || true)
    if [[ -z "$iface" ]]; then
        iface=$(ip -o link show 2>/dev/null | awk -F': ' '$2 !~ /lo|vir/ {print $2}' | head -n1 || true)
    fi
    echo "${iface:-eth0}"
}

obtener_subred_local() {
    local iface
    iface=$(obtener_interfaz_activa)
    local subred
    subred=$(ip route show dev "$iface" scope link 2>/dev/null | awk '{print $1}' | head -n1)
    if [[ -z "$subred" ]]; then
        local ip
        ip=$(obtener_ip_local)
        subred="$(echo "$ip" | cut -d'.' -f1-3).0/24"
    fi
    echo "$subred"
}

validar_formato_hostname() {
    local h="$1"
    # RFC 1123: minúsculas, números y guiones, entre 1 y 63 caracteres, sin empezar ni terminar con guión
    if [[ "$h" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
        return 0
    else
        return 1
    fi
}

resolver_hostname_ip() {
    local ip="$1"
    local nombre=""

    # 1. Intentar mDNS con avahi-resolve si está disponible
    if command -v avahi-resolve >/dev/null 2>&1; then
        nombre=$(avahi-resolve -a "$ip" 2>/dev/null | awk '{print $2}' | sed 's/\.local$//' || true)
    fi

    # 2. Intentar getent hosts (/etc/hosts y DNS local)
    if [[ -z "$nombre" ]] && command -v getent >/dev/null 2>&1; then
        nombre=$(getent hosts "$ip" 2>/dev/null | awk '{print $2}' || true)
    fi

    # 3. Intentar consulta inversa con host
    if [[ -z "$nombre" ]] && command -v host >/dev/null 2>&1; then
        nombre=$(host "$ip" 2>/dev/null | awk '/pointer/ {print $NF}' | sed 's/\.$//' || true)
    fi

    # Limpiar sufijo de dominio
    nombre=$(echo "$nombre" | cut -d'.' -f1)

    echo "${nombre:-desconocido}"
}

