#!/bin/bash

while true; do
  clear
  echo "========== ASISTENTE POITE (Prof. Gabriel Vázquez) =========="
  echo "1) 🌐 Red y conectividad"
  echo "2) 👥 Usuarios y cuentas"
  echo "3) 💻 Información del sistema"
  echo "4) 🧹 Mantenimiento"
  echo "0) Salir"
  echo "====================================="
  echo -n "Seleccione una opción: "
  read opcion

  case $opcion in
    1) bash ./submenus/red.sh ;;
    2) bash ./submenus/usuarios.sh ;;
    3) bash ./submenus/sistema.sh ;;
    4) bash ./submenus/mantenimiento.sh ;;
    0) echo "Saliendo..."; break ;;
    *) echo "Opción inválida"; read ;;
  esac
done
echo "Gracias por usar el asistente. ¡Hasta luego!"
# Fin del script
# Este script es un menú principal para un asistente de administración de sistemas.
# Permite al usuario seleccionar diferentes opciones relacionadas con la red, usuarios, información del sistema y mantenimiento.
# Cada opción ejecuta un script diferente ubicado en la carpeta "submenus".
# El script se ejecuta en un bucle infinito hasta que el usuario selecciona la opción de salir (0).
# Se utiliza "clear" para limpiar la pantalla antes de mostrar el menú.
# El menú incluye una cabecera con el nombre del asistente y un pie de página que agradece al usuario por usar el asistente.
# El script utiliza "read" para capturar la entrada del usuario y "case" para manejar las diferentes opciones seleccionadas.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.