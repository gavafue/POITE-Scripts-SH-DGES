#!/bin/bash

set -euo pipefail

# ===============================================
# Registrar la dirección MAC del dispositivo
# Autor: Optimizado para entornos educativos (POITE)
# ===============================================

# Ruta al archivo donde se guardarán las MACs
ARCHIVO_MAC="./RegistrarIP/macs.txt"

# Crear el directorio si no existe
DIRECTORIO_MAC=$(dirname "$ARCHIVO_MAC")
if [ ! -d "$DIRECTORIO_MAC" ]; then
    echo "📁 Creando directorio $DIRECTORIO_MAC"
    sudo mkdir -p "$DIRECTORIO_MAC"
    sudo chown "$USER":"$USER" "$DIRECTORIO_MAC"
fi

# Función para pausar antes de salir
pausa() {
    read -p "Presione enter para continuar..."
}

# Función para detectar tipo de interfaz
tipo_interfaz() {
    local ifname=$1
    if [[ "$ifname" =~ ^w ]]; then
        echo "WiFi"
    elif [[ "$ifname" =~ ^e ]]; then
        echo "Ethernet"
    else
        echo "Otro tipo"
    fi
}

# Función para registrar la MAC
registrar_mac() {
    echo "🔍 Detectando interfaces de red disponibles..."
    interfaces=($(ip -o link show | awk -F': ' '$2 !~ /lo|vir/ {print $2}'))

    if [ ${#interfaces[@]} -eq 0 ]; then
        echo "❌ No se encontró ninguna interfaz de red válida."
        pausa
        exit 1
    elif [ ${#interfaces[@]} -eq 1 ]; then
        interfaz=${interfaces[0]}
        echo "✅ Usando interfaz detectada automáticamente: $interfaz"
    else
        echo "⚠️ Se detectaron múltiples interfaces. Seleccione una:"
        select opcion in "${interfaces[@]}"; do
            if [[ -n "$opcion" ]]; then
                interfaz="$opcion"
                break
            else
                echo "❌ Opción inválida. Intente de nuevo."
            fi
        done
    fi

    # Mostrar tipo de interfaz
    tipo=$(tipo_interfaz "$interfaz")
    echo "🔧 La interfaz '$interfaz' es de tipo: $tipo"

    # Obtener la dirección MAC
    mac=$(cat /sys/class/net/"$interfaz"/address)

    # Validar si ya está registrada
    if grep -Fxq "$mac" "$ARCHIVO_MAC" 2>/dev/null; then
        echo "✔️ La MAC $mac ya está registrada en $ARCHIVO_MAC"
        pausa
        exit 0
    else
        echo "$mac" >> "$ARCHIVO_MAC"
        echo "➕ La MAC $mac ha sido registrada en $ARCHIVO_MAC"
    fi
}

# Ejecutar
registrar_mac
echo "✅ Proceso de registro de MAC completado."
echo "Volviendo al menú principal..."
pausa

# Fin del script
# Este script registra la dirección MAC de la interfaz de red del dispositivo.
# Se asegura de que el directorio de almacenamiento exista y permite al usuario seleccionar la interfaz de red.
# Si la MAC ya está registrada, informa al usuario y termina.
# Se recomienda ejecutar este script con permisos de superusuario para un funcionamiento óptimo.