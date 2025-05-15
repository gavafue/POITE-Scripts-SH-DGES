#!/bin/bash

set -euo pipefail

# =====================================
# Verificar y agregar repositorios APT
# =====================================
# Autor: Gabriel Vázquez
# Ubuntu focal (20.04)
# =====================================

# Repositorios necesarios
REPOS=(
  "deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse"
  "deb-src http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse"
  "deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse"
  "deb-src http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse"
  "deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse"
  "deb-src http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse"
  "deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse"
  "deb-src http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse"
  "deb http://archive.canonical.com/ubuntu focal partner"
  "deb-src http://archive.canonical.com/ubuntu focal partner"
)

SOURCES_LIST="/etc/apt/sources.list"
BACKUP_FILE="/etc/apt/sources.list.bak"

# Crear copia de seguridad si no existe
if [ ! -f "$BACKUP_FILE" ]; then
  echo "🔒 Creando copia de respaldo en $BACKUP_FILE"
  sudo cp "$SOURCES_LIST" "$BACKUP_FILE"
fi

# Verificar y agregar repositorios
for repo in "${REPOS[@]}"; do
  if grep -Fxq "$repo" "$SOURCES_LIST"; then
    echo "✔️ Repositorio ya presente: $repo"
  else
    echo "➕ Agregando repositorio: $repo"
    echo "$repo" | sudo tee -a "$SOURCES_LIST" > /dev/null
  fi
done

echo -e "\n✅ Revisión completa. Puede ejecutar: sudo apt update"
echo "Volviendo al menú principal..."
read -p "Presione enter para continuar..."
# Fin del script
# Este script verifica y agrega repositorios APT necesarios para Ubuntu 20.04 (focal).
# Primero, crea una copia de seguridad del archivo de fuentes APT si no existe.
# Luego, verifica si cada repositorio ya está presente en el archivo de fuentes.
# Si un repositorio no está presente, lo agrega.
# Al final, muestra un mensaje de confirmación y espera a que el usuario presione enter para continuar y volver al menú principal.