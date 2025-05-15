#!/bin/bash

read -p "Ingrese el nombre del nuevo usuario predeterminado para login automático: " nuevo_usuario

if id "$nuevo_usuario" &>/dev/null; then
  archivo_lightdm="/etc/lightdm/lightdm.conf"

  if [[ -f "$archivo_lightdm" ]]; then
    sudo sed -i "s/^autologin-user=.*/autologin-user=$nuevo_usuario/" "$archivo_lightdm"
    echo "✅ Usuario predeterminado cambiado a '$nuevo_usuario'."
  else
    echo "⚠️ No se encontró el archivo de configuración de lightdm."
  fi
else
  echo "⚠️ El usuario '$nuevo_usuario' no existe."
fi

read -p "Presione enter para continuar..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script cambia el usuario predeterminado para el inicio de sesión automático en un sistema Linux que utiliza lightdm.
# Solicita al usuario que ingrese el nombre del nuevo usuario y verifica si existe.
# Si el usuario existe, se modifica el archivo de configuración de lightdm para establecer el nuevo usuario como predeterminado.
# Si el usuario no existe, se muestra un mensaje de advertencia.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.