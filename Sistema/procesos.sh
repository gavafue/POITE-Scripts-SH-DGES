#!/bin/bash
clear
echo ">>> PROCESOS EN EJECUCIÓN <<<"
ps aux | less
echo ""
read -p "Presione Enter para volver al menú..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script muestra los procesos en ejecución en el sistema utilizando el comando `ps aux`.
# La salida se envía a `less` para permitir la navegación por la información.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.