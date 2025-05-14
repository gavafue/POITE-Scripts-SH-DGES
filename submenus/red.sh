#!/bin/bash

while true; do
  clear
  echo "=== Menú: Red y conectividad ==="
  echo "1) Registrar IP"
  echo "2) Configurar proxy DGES"
  echo "3) Reiniciar red"
  echo "4) Chequear repositorios"
  echo "0) Volver"
  echo "================================"
  echo -n "Seleccione una opción: "
  read opcion

  case $opcion in
    1) bash ../Red/registrar_ip.sh ;;
    2) bash ../Red/proxy_DGES.sh ;;
    3) bash ../Red/reiniciar_red.sh ;;
    4) bash ../Red/chequear_repositorios_ubuntu20-04.sh ;;
    0) break ;;
    *) echo "Opción inválida"; read ;;
  esac
done
echo "Volviendo al menú principal..."
# Fin del script
# Este script es un menú para la sección de red y conectividad del asistente de administración de sistemas. 