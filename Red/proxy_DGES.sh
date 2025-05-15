#!/bin/bash

set -euo pipefail

# ============================================
# Configurar proxy HTTP/HTTPS para APT
# Autor: Optimizado para uso institucional
# ============================================

PROXY_IP="10.4.142.24:8080"
APT_CONF_FILE="/etc/apt/apt.conf.d/proxy.conf"
BACKUP_FILE="/etc/apt/apt.conf.d/proxy.conf.bak"

proxy_http="Acquire::http::proxy \\\"http://$PROXY_IP\\\";"
proxy_https="Acquire::https::proxy \\\"http://$PROXY_IP\\\";"

# Crear respaldo si no existe
if [ -f "$APT_CONF_FILE" ] && [ ! -f "$BACKUP_FILE" ]; then
  echo "🔒 Creando respaldo de proxy.conf en $BACKUP_FILE"
  sudo cp "$APT_CONF_FILE" "$BACKUP_FILE"
fi

# Crear el archivo si no existe
if [ ! -f "$APT_CONF_FILE" ]; then
  echo "📝 Creando archivo $APT_CONF_FILE"
  sudo touch "$APT_CONF_FILE"
fi

# Añadir proxy HTTP si no está presente
if ! grep -Fxq "Acquire::http::proxy \"http://$PROXY_IP\";" "$APT_CONF_FILE"; then
  echo "➕ Añadiendo proxy HTTP"
  echo "Acquire::http::proxy \"http://$PROXY_IP\";" | sudo tee -a "$APT_CONF_FILE" > /dev/null
else
  echo "✔️ Proxy HTTP ya está configurado"
fi

# Añadir proxy HTTPS si no está presente
if ! grep -Fxq "Acquire::https::proxy \"http://$PROXY_IP\";" "$APT_CONF_FILE"; then
  echo "➕ Añadiendo proxy HTTPS"
  echo "Acquire::https::proxy \"http://$PROXY_IP\";" | sudo tee -a "$APT_CONF_FILE" > /dev/null
else
  echo "✔️ Proxy HTTPS ya está configurado"
fi

echo "✅ Configuración completada en $APT_CONF_FILE"
echo "Volviendo al menú principal..."
read -p "Presione enter para continuar..."
# Fin del script
# Este script configura un proxy HTTP/HTTPS para APT en un sistema Linux.
# Primero, verifica si el archivo de configuración del proxy ya existe y crea una copia de seguridad si no existe.
# Luego, verifica si el archivo de configuración de APT existe y lo crea si no existe.
# A continuación, añade la configuración del proxy HTTP y HTTPS al archivo de configuración de APT si no están presentes.
# Finalmente, muestra un mensaje de confirmación y espera a que el usuario presione enter para continuar y volver al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.