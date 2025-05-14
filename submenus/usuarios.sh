#!/bin/bash

while true; do
  clear
  echo "=== 👥 Menú: Usuarios y Cuentas ==="
  echo "1) Crear usuario liceo"
  echo "2) Cambiar usuario predeterminado"
  echo "3) Activar acceso SSH"
  echo "0) Volver al menú principal"
  echo "==================================="
  read -p "Seleccione una opción: " opcion

  case $opcion in
    1) bash ../Usuarios/userliceo.sh ;;
    2) bash ../Usuarios/cambiar_usuario.sh ;;
    3) bash ../Usuarios/ssh.sh ;;
    0) break ;;
    *) echo "Opción inválida"; read -p "Presione enter para continuar..." ;;
  esac
done
echo "Volviendo al menú principal..."
# Fin del script
# Este script es un menú para la gestión de usuarios y cuentas en un sistema Linux.
# Permite al usuario seleccionar diferentes opciones relacionadas con la creación de usuarios, cambio de usuario predeterminado y activación de acceso SSH.
# Cada opción ejecuta un script diferente ubicado en la carpeta "Usuarios". 