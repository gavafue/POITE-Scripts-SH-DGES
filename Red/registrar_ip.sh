#!/bin/bash

set -euo pipefail

# ===============================================
# Registrar la IP del host en un archivo de texto
# Autor: Optimizado para entornos educativos (POITE)
# ===============================================

# Ruta al archivo donde se guardarán las IPs
ARCHIVO_IP="./RegistrarIP/ips.txt"

# Crear el directorio si no existe
DIRECTORIO_IP=$(dirname "$ARCHIVO_IP")
if [ ! -d "$DIRECTORIO_IP" ]; then
  echo "📁 Creando directorio $DIRECTORIO_IP"
  sudo mkdir -p "$DIRECTORIO_IP"
  sudo chown "$USER":"$USER" "$DIRECTORIO_IP"
fi

# Función para registrar la IP primaria del host
registrar_ip() {
    # Obtener la IP del host (ignora localhost, docker, etc.)
    ip_host=$(ip route get 1.1.1.1 | grep -oP 'src \K[0-9.]+')

    # Validar si ya está registrada
    if grep -Fxq "$ip_host" "$ARCHIVO_IP" 2>/dev/null; then
        echo "✔️ La IP $ip_host ya está registrada en $ARCHIVO_IP"
    else
        echo "$ip_host" >> "$ARCHIVO_IP"
        echo "➕ La IP $ip_host ha sido registrada en $ARCHIVO_IP"
    fi
}

# Ejecutar
registrar_ip
echo "✅ Proceso de registro de IP completado."
echo "Volviendo al menú principal..."
read -p "Presione enter para continuar..."
# Fin del script
# Este script registra la dirección IP del host en un archivo de texto.
# Primero, verifica si el directorio donde se guardará el archivo de IPs existe y lo crea si no existe.
# Luego, obtiene la dirección IP del host (ignorando localhost y otras interfaces no deseadas).
# A continuación, verifica si la IP ya está registrada en el archivo. Si no lo está, la agrega.
# Finalmente, muestra un mensaje de confirmación y espera a que el usuario presione enter para continuar y volver al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.