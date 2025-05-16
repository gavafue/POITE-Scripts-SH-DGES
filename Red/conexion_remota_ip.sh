#!/bin/bash

ARCHIVO_IPS="./RegistrarIP/ips.txt"
SCRIPT_REMOTO="./RegistrarIP/remoto.sh"

clear
read -p "👤 Ingrese el nombre de usuario remoto: " USUARIO
read -s -p "🔐 Ingrese la contraseña sudo para los hosts remotos (dejar vacío si no se usará): " SUDO_PASS
echo
echo "🔄 Ejecutando script remoto en los hosts listados..."

# Verificar archivo
if [[ ! -f "$ARCHIVO_IPS" ]]; then
    echo "❌ No se encontró el archivo de IPs: $ARCHIVO_IPS"
    exit 1
fi

mapfile -t ips_array < "$ARCHIVO_IPS"

for ip in "${ips_array[@]}"; do
    ip=$(echo "$ip" | xargs)
    [[ -z "$ip" || "$ip" == \#* ]] && continue

    echo "➡️ Procesando IP: $ip"
    exito=false

    for intento in {1..3}; do
        echo "🔑 Intento $intento/3 con clave SSH..."
        if ssh -o BatchMode=yes -o ConnectTimeout=5 "$USUARIO@$ip" 'echo "Conexión con clave OK."' &>/dev/null; then
            echo "✅ Conectado con clave SSH."
            exito=true
            break
        else
            echo "❌ Falló intento con clave SSH."
        fi
    done

    if ! $exito; then
        for intento in {1..3}; do
            echo "🔐 Intento $intento/3 con contraseña..."
            sshpass -p "$SUDO_PASS" ssh -o StrictHostKeyChecking=no "$USUARIO@$ip" 'echo "Conexión con contraseña OK."' &>/dev/null
            if [[ $? -eq 0 ]]; then
                echo "✅ Conectado con contraseña."
                exito=true
                break
            else
                echo "❌ Falló intento con contraseña."
            fi
        done
    fi

    if $exito; then
        echo "📤 Copiando script remoto a $ip..."
        sshpass -p "$SUDO_PASS" scp -o StrictHostKeyChecking=no "$SCRIPT_REMOTO" "$USUARIO@$ip:/tmp/script_remoto.sh"

        echo "🚀 Ejecutando script remoto en $ip..."
        sshpass -p "$SUDO_PASS" ssh -tt -o StrictHostKeyChecking=no "$USUARIO@$ip" "export PASSWORD='$SUDO_PASS'; bash /tmp/script_remoto.sh"

        echo "🧹 Limpiando archivo temporal..."
        sshpass -p "$SUDO_PASS" ssh -o StrictHostKeyChecking=no "$USUARIO@$ip" "rm /tmp/script_remoto.sh"

        echo "🏁 Script finalizado en $ip."
        echo "----------------------------------------"
    else
        echo "⚠️ No se pudo conectar con $ip. Se omite."
        echo "----------------------------------------"
    fi
done

echo "✅ Todos los procesos finalizados."
read -p "Presione Enter para salir..."
