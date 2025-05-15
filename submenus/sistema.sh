#!/bin/bash

# Función para mostrar el menú
mostrar_menu_sistema() {
    clear
    echo "----- INFORMACIÓN DEL SISTEMA -----"
    echo "1) Mostrar información del kernel"
    echo "2) Mostrar información de la CPU"
    echo "3) Mostrar información de memoria"
    echo "4) Mostrar información de discos"
    echo "5) Mostrar información del sistema operativo"
    echo "6) Mostrar información de variables de entorno"
    echo "7) Mostrar información de procesos en ejecución"
    echo "8) Mostrar información de hardware (lshw)"
    echo "9) Mostrar información completa del sistema"
    echo "0) Volver al menú principal"
    echo "----------------------------------"
    echo -n "Seleccione una opción: "
}

while true; do
    mostrar_menu_sistema
    read opcion
    
    case $opcion in
        1) bash ./Sistema/kernel.sh ;;
        2) bash ./Sistema/cpu.sh ;;
        3) bash ./Sistema/memoria.sh ;;
        4) bash ./Sistema/discos.sh ;;
        5) bash ./Sistema/so.sh ;;
        6) bash ./Sistema/variables.sh ;;
        7) bash ./Sistema/procesos.sh ;;
        8) bash ./Sistema/hardware.sh ;;
        9) bash ./Sistema/completo.sh ;;
        0) break ;;
        *) 
            echo "Opción inválida"
            read -p "Presione Enter para continuar..."
            ;;
    esac
done