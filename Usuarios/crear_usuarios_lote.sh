#!/bin/bash

read -p "Ingrese la ruta del archivo CSV (usuario,contraseña): " archivo

if [[ ! -f "$archivo" ]]; then
  echo "⚠️ Archivo no encontrado."
  exit 1
fi

while IFS=, read -r usuario password; do
  if id "$usuario" &>/dev/null; then
    echo "⏭ Usuario '$usuario' ya existe. Omitido."
  else
    sudo useradd -m "$usuario"
    echo "$usuario:$password" | sudo chpasswd
    echo "✅ Usuario '$usuario' creado."
  fi
done < "$archivo"

read -p "Presione enter para continuar..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script crea usuarios en el sistema Linux a partir de un archivo CSV que contiene pares de usuario y contraseña.
# Solicita al usuario que ingrese la ruta del archivo CSV y verifica si existe.
# Si el archivo no existe, se muestra un mensaje de advertencia y se sale del script.
# Si el archivo existe, se lee línea por línea y se crea cada usuario con su respectiva contraseña.
# Si el usuario ya existe, se omite y se muestra un mensaje.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.
# Se recomienda utilizar un archivo CSV con el siguiente formato:
# usuario1,contraseña1
# usuario2,contraseña2
# usuario3,contraseña3