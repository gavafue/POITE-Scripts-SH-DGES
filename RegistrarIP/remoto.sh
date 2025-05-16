#!/bin/bash

echo "🚀 Iniciando en $(hostname)..."

# Si se pasó la contraseña y es necesario sudo
if [[ -n "$PASSWORD" ]]; then
  echo "🔧 Ejecutando tareas con sudo..."
  echo "$PASSWORD" | sudo -S apt update
  echo "$PASSWORD" | sudo -S apt install -y geogebra
fi

# Tareas independientes
# Más tareas...
echo "🛠️ Ejecutando otros pasos..."
# ...

echo "🏁 Fin del script remoto."
