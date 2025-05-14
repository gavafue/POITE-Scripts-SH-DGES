#!/bin/bash

read -p "Ingrese el nombre del usuario a eliminar: " usuario

if id "$usuario" &>/dev/null; then
  read -p "¿Desea eliminar también su carpeta personal? (s/n): " respuesta
  if [[ "$respuesta" == "s" ]]; then
    sudo deluser --remove-home "$usuario"
  else
    sudo deluser "$usuario"
  fi
  echo "✅ Usuario '$usuario' eliminado."
else
  echo "⚠️ El usuario '$usuario' no existe."
fi

read -p "Presione enter para continuar..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script elimina un usuario del sistema Linux.
# Solicita al usuario que ingrese el nombre del usuario a eliminar y verifica si existe.
# Si el usuario existe, se pregunta si desea eliminar también su carpeta personal.
# Si la respuesta es afirmativa, se utiliza el comando `deluser` con la opción `--remove-home` para eliminar al usuario y su carpeta personal.
# Si la respuesta es negativa, solo se elimina al usuario.
# Si el usuario no existe, se muestra un mensaje de advertencia.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.