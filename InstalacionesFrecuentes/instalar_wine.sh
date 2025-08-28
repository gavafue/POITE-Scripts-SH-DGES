#!/bin/bash
# Instalador automatizado de WineHQ + Astrometrica (robusto)
# Uso: sudo ./instalar_astrometrica.sh

set -euo pipefail
trap 'echo "❌ Error en la línea $LINENO. Abortando." >&2' ERR

# --- Funciones auxiliares ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "⚠️  Este script debe ejecutarse con sudo o como root."
        exit 1
    fi
}

check_command() {
    local pkg=$1
    local cmd=$2
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "📦 Instalando dependencia: $pkg..."
        apt-get install -y "$pkg"
    else
        echo "✅ Dependencia detectada: $pkg"
    fi
}

download_file() {
    local url=$1
    local output=$2
    echo "🌍 Descargando: $url"
    if ! wget -q --tries=5 --timeout=20 -O "$output" "$url"; then
        echo "❌ Error al descargar $url"
        exit 1
    fi
}

# --- Inicio ---
check_root
echo "🔍 Verificando dependencias básicas..."
apt update
apt upgrade -y

# Dependencias esenciales
check_command wget wget
check_command gpg gpg
check_command dpkg dpkg
check_command apt apt
check_command software-properties-common add-apt-repository || true
check_command lsb-release lsb_release || true
check_command cabextract cabextract || true   # útil para wine
check_command unzip unzip || true

# --- Arquitectura i386 ---
echo "🛠️  Habilitando arquitectura i386 (si no está habilitada)..."
if ! dpkg --print-foreign-architectures | grep -q i386; then
    dpkg --add-architecture i386
    echo "✅ Arquitectura i386 habilitada."
else
    echo "ℹ️  Arquitectura i386 ya estaba habilitada."
fi

# --- Keyrings ---
echo "📂 Creando carpeta de keyrings..."
mkdir -pm755 /etc/apt/keyrings

# --- Clave GPG de WineHQ ---
echo "🔑 Descargando clave GPG de WineHQ..."
download_file "https://dl.winehq.org/wine-builds/winehq.key" "/tmp/winehq.key"
gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key /tmp/winehq.key

# --- Detectar distro ---
DISTRO=$(lsb_release -cs || echo "focal")  # fallback a focal
echo "🌍 Detectada distribución: $DISTRO"
SOURCE_FILE="/etc/apt/sources.list.d/winehq-${DISTRO}.sources"

# --- Sources ---
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "📥 Descargando sources para $DISTRO..."
    if ! download_file "https://dl.winehq.org/wine-builds/ubuntu/dists/${DISTRO}/winehq-${DISTRO}.sources" "$SOURCE_FILE"; then
        echo "⚠️  No se encontró fuente para $DISTRO. Usando focal como fallback..."
        download_file "https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources" "/etc/apt/sources.list.d/winehq-focal.sources"
    fi
else
    echo "✅ Sources ya existen en $SOURCE_FILE"
fi

# --- Update ---
echo "🔄 Actualizando repositorios..."
apt-get update -y || true

# --- Instalación WineHQ ---
echo "🍷 Instalando WineHQ estable..."
if ! apt-get install -y --install-recommends winehq-stable; then
    echo "⚠️  Error al instalar WineHQ estable. Reparando dependencias..."
    apt-get --fix-broken install -y
    apt-get install -y --install-recommends winehq-stable || true
fi

# --- Configurar wineprefix ---
USER_HOME=$(eval echo "~$SUDO_USER")
WINEPREFIX="$USER_HOME/.wine"
echo "📂 Configurando wineprefix en $WINEPREFIX..."
sudo -u "$SUDO_USER" WINEPREFIX="$WINEPREFIX" wineboot --init || true