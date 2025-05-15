#!/bin/bash

set -euo pipefail

# ============================================
# Sincronización de hora del sistema con NTP
# Optimizado para entornos educativos (POITE)
# ============================================

# Función de log
log() {
  echo -e "\n🕐 $1"
}

# 1. Actualizar lista de paquetes
log "1. Actualizando lista de paquetes..."
sudo apt-get update

# 2. Instalar NTP si no está instalado
log "2. Instalando NTP si es necesario..."
sudo apt-get install -y ntp

# 3. Configurar servidores NTP (solo si no existen)
log "3. Verificando y agregando servidores NTP a /etc/ntp.conf..."

NTP_CONF="/etc/ntp.conf"
NTP_SERVERS=(
  "server time.google.com iburst"
  "server 0.ubnt.pool.ntp.org iburst"
  "server 1.ubnt.pool.ntp.org iburst"
  "server 2.ubnt.pool.ntp.org iburst"
  "server 3.ubnt.pool.ntp.org iburst"
)

for server in "${NTP_SERVERS[@]}"; do
  if ! grep -qxF "$server" "$NTP_CONF"; then
    echo "$server" | sudo tee -a "$NTP_CONF" > /dev/null
    log "➕ Agregado: $server"
  else
    log "✔️ Ya presente: $server"
  fi
done

# 4. Reiniciar el servicio NTP
log "4. Reiniciando el servicio NTP..."
sudo systemctl restart ntp

# 5. Verificar estado del servicio
log "5. Estado del servicio NTP:"
sudo systemctl --no-pager status ntp

# 6. Sincronizar manualmente con servidor (por si ntpdate aún es útil)
log "6. Sincronizando hora manualmente con time.google.com..."
sudo ntpdate -u time.google.com || log "ℹ️ ntpdate puede estar obsoleto. Confía en el servicio NTP activo."

# 7. Mostrar configuración del reloj del sistema
log "7. Estado actual del reloj del sistema:"
timedatectl

# 8. Configurar zona horaria
log "8. Configurando zona horaria a America/Montevideo..."
sudo timedatectl set-timezone America/Montevideo

# 9. Sincronizar reloj de hardware
log "9. Sincronizando reloj de hardware con el sistema operativo..."
sudo hwclock --systohc

# 10. Recordatorio sobre puertos
log "🔐 Asegúrate de que el puerto UDP 123 esté habilitado en tu red para NTP."

log "✅ Proceso de sincronización de hora finalizado."
read -p "Presione [Enter] para continuar..."
log "Regresando al menú principal..."
# Fin del script
# Este script sincroniza la hora del sistema con servidores NTP.
# Primero, actualiza la lista de paquetes e instala NTP si no está instalado.
# Luego, verifica y agrega servidores NTP a la configuración si no están presentes.
# Después, reinicia el servicio NTP y verifica su estado.
# Luego, sincroniza manualmente la hora con un servidor NTP y muestra el estado actual del reloj del sistema.
# A continuación, configura la zona horaria a "America/Montevideo" y sincroniza el reloj de hardware con el sistema operativo.
# Finalmente, recuerda habilitar el puerto UDP 123 en la red para NTP y muestra un mensaje de finalización.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.