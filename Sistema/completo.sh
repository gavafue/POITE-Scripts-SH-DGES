#!/bin/bash
clear
echo ">>> INFORMACIÓN COMPLETA DEL SISTEMA <<<"
echo "===== Kernel ====="
uname -a
echo ""
echo "===== Sistema Operativo ====="
cat /etc/os-release 2>/dev/null || cat /etc/*release 2>/dev/null
echo ""
echo "===== CPU ====="
lscpu
echo ""
echo "===== Memoria ====="
free -h
echo ""
echo "===== Discos ====="
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
echo ""
df -h
echo ""
read -p "Presione Enter para volver al menú..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script muestra información completa del sistema, incluyendo el kernel, el sistema operativo, la CPU, la memoria y los discos.
# Utiliza comandos como `uname`, `cat`, `lscpu`, `free` y `lsblk` para obtener la información.
# La salida incluye detalles sobre el kernel, la distribución del sistema operativo, la arquitectura de la CPU, el uso de memoria y el estado de los discos.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.