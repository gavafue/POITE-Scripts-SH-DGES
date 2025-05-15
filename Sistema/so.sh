#!/bin/bash
clear
echo ">>> INFORMACIÓN DEL SISTEMA OPERATIVO <<<"
if [ -f /etc/os-release ]; then
    cat /etc/os-release
elif [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release
else
    echo "No se pudo determinar la distribución"
fi
echo ""
read -p "Presione Enter para volver al menú..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script muestra información del sistema operativo utilizando los archivos de configuración típicos de Linux.
# Dependiendo de la distribución, se utiliza `/etc/os-release` o `/etc/lsb-release` para obtener información sobre la versión y el nombre de la distribución.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.
