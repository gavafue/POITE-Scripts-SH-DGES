#!/bin/bash

read -p "Ingrese el nombre del nuevo usuario (ej: liceo): " user

if id "$user" &>/dev/null; then
  echo "⚠️ El usuario '$user' ya existe."
else
  sudo adduser "$user"
  sudo usermod -aG sudo "$user"
  echo "✅ Usuario '$user' creado y agregado al grupo sudo."
fi

read -p "Presione enter para continuar..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script crea un nuevo usuario en el sistema y lo agrega al grupo sudo.
# Si el usuario ya existe, se muestra un mensaje de advertencia.
# El script solicita al usuario que ingrese el nombre del nuevo usuario y luego verifica si ya existe.
# Si el usuario no existe, se crea y se le otorgan privilegios de sudo.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.