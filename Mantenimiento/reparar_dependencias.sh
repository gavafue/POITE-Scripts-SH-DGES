#!/bin/bash

set -euo pipefail

# ========================================================
# Script de Reparación General del Sistema Ubuntu
# Autor: Optimizado para POITE (Entornos Educativos)
# ========================================================

log() {
  echo -e "\n📌 $1"
}

log "Iniciando la reparación del sistema..."

# 1. Actualizar lista de repositorios
log "1. Actualizando lista de repositorios..."
sudo apt update

# 2. Reconfigurar paquetes pendientes
log "2. Reconfigurando paquetes pendientes..."
sudo dpkg --configure -a

# 3. Reparar dependencias rotas
log "3. Reparando dependencias rotas..."
sudo apt --fix-broken install -y

# 4. Forzar instalación de dependencias faltantes
log "4. Forzando instalación de dependencias faltantes..."
sudo apt install -f -y

# 5. Actualizar paquetes corrigiendo archivos faltantes
log "5. Actualizando paquetes (corrigiendo archivos faltantes)..."
sudo apt upgrade --fix-missing -y

# 6. Actualización completa del sistema
log "6. Realizando actualización completa (full-upgrade)..."
sudo apt full-upgrade -y

# 7. Reinstalar paquetes esenciales (adaptar si es Xubuntu/Lubuntu)
log "7. Reinstalando paquetes esenciales (ubuntu-desktop, linux-generic)..."
sudo apt install --reinstall ubuntu-desktop linux-generic -y

# 8. Eliminar paquetes obsoletos y dependencias innecesarias
log "8. Ejecutando autoremove y purge..."
sudo apt autoremove --purge -y

# 9. Limpiar caché de paquetes
log "9. Limpiando caché de paquetes descargados..."
sudo apt clean
sudo apt autoclean

# 10. Verificar sistema de archivos (requiere reinicio si root está montado)
log "10. Verificando sistema de archivos raíz (puede requerir reinicio)..."
echo -e "\n⚠️  Si / está montado, fsck no puede ejecutarse completamente en caliente."
echo "Se recomienda programar una verificación al reiniciar:"
sudo touch /forcefsck

# 11. Verificar salud del disco con SMART
log "11. Verificando estado SMART del disco..."

# Asegurarse de que smartmontools esté instalado
sudo apt install -y smartmontools

# Detectar disco principal
DISCO=$(lsblk -ndo NAME,TYPE | awk '$2 == "disk" {print $1; exit}')
if [ -n "$DISCO" ]; then
  echo "Dispositivo detectado: /dev/$DISCO"
  sudo smartctl --health /dev/$DISCO
else
  echo "❌ No se detectó disco válido para verificar SMART."
fi

log "✅ Reparación del sistema completada. Reinicia el sistema si es necesario."
read -p "Presione enter para continuar..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script realiza una serie de tareas de mantenimiento y reparación en un sistema Ubuntu.
# Primero, actualiza la lista de repositorios y reconfigura los paquetes pendientes.
# Luego, repara las dependencias rotas y fuerza la instalación de dependencias faltantes.
# Después, actualiza los paquetes corrigiendo archivos faltantes y realiza una actualización completa del sistema.
# A continuación, reinstala paquetes esenciales como ubuntu-desktop y linux-generic.
# Luego, elimina paquetes obsoletos y dependencias innecesarias, y limpia la caché de paquetes descargados.
# Después, verifica el sistema de archivos raíz y programa una verificación al reiniciar si es necesario.
# Finalmente, verifica el estado SMART del disco principal y muestra un mensaje de finalización.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.