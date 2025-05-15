#!/bin/bash
clear
echo ">>> INFORMACIÓN DE HARDWARE (lshw) <<<"
if ! command -v lshw &> /dev/null; then
    read -p "lshw no está instalado. ¿Desea instalarlo? (s/n): " respuesta
    if [[ "$respuesta" =~ [sS] ]]; then
        sudo apt install lshw -y
    else
        exit 0
    fi
fi
sudo lshw | less
echo ""
read -p "Presione Enter para volver al menú..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script muestra información detallada sobre el hardware del sistema utilizando el comando `lshw`.
# Si `lshw` no está instalado, se le pregunta al usuario si desea instalarlo.
# Si el usuario acepta, se instala `lshw` utilizando `apt`.
# La salida se envía a `less` para permitir la navegación por la información.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.
