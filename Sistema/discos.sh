#!/bin/bash
clear
echo ">>> INFORMACIÓN DE DISCOS <<<"
echo "Particiones:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
echo ""
echo "Uso de disco:"
df -h
echo ""
read -p "Presione Enter para volver al menú..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script muestra información sobre los discos del sistema utilizando los comandos `lsblk` y `df -h`.
# `lsblk` muestra las particiones y su tamaño, tipo, punto de montaje y sistema de archivos.
# `df -h` muestra el uso del disco en un formato legible para humanos (human-readable).
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.