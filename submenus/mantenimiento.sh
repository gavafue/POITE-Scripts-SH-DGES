#!/bin/bash

while true; do
  clear
  echo "=== 🧹 Menú: Mantenimiento ==="
  echo "1) Arreglar reloj de Ubuntu (servidor NTP)"
  echo "2) Reparar dependencias (apt-get install -f)"
  echo "3) Instalar servicio SSH"
  echo "0) Volver al menú principal"
  echo "=============================="
  read -p "Seleccione una opción: " opcion

  case $opcion in
    1) bash ../Mantenimiento/arreglar_reloj_ubuntu.sh ;;
    2) bash ../Mantenimiento/reparar_dependencias.sh ;;
    3) bash ../Mantenimiento/ssh.sh ;;
    0) break ;;
    *) echo "Opción inválida"; read -p "Presione enter para continuar..." ;;
  esac
done
echo "Volviendo al menú principal..."
# Fin del script
# Este script es un menú para la sección de mantenimiento del asistente de administración de sistemas.
# Permite al usuario seleccionar diferentes opciones relacionadas con la limpieza del sistema, montaje de dispositivos USB y reparación del sistema básico.
# Cada opción ejecuta un script diferente ubicado en la carpeta "Mantenimiento".
# El script se ejecuta en un bucle infinito hasta que el usuario selecciona la opción de volver al menú principal (0).