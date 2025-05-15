#!/bin/bash

read -p "Ingrese el nombre del usuario para cambiar la contraseña: " usuario

if id "$usuario" &>/dev/null; then
  sudo passwd "$usuario"
else
  echo "⚠️ El usuario '$usuario' no existe."
fi

read -p "Presione enter para continuar..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script cambia la contraseña de un usuario en el sistema Linux.
# Solicita al usuario que ingrese el nombre del usuario y verifica si existe.
# Si el usuario existe, se utiliza el comando `passwd` para cambiar la contraseña.
# Si el usuario no existe, se muestra un mensaje de advertencia.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.