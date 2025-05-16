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

# Fin del script
# Este script remoto se ejecuta en los equipos de red.
# Se encarga de instalar geogebra y realizar otras tareas necesarias.
# Asegúrese de que el script remoto tenga permisos de ejecución.
# Se recomienda ejecutarlo con permisos de superusuario para un funcionamiento óptimo.