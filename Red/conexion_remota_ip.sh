#!/bin/bash

ARCHIVO_IPS="./RegistrarIP/ips.txt"
SCRIPT_REMOTO="./RegistrarIP/remoto.sh"

clear
read -p "👤 Ingrese el nombre de usuario remoto: " USUARIO
read -s -p "🔐 Ingrese la contraseña sudo/SSH para los hosts remotos (dejar vacío si no se usará): " SUDO_PASS
echo
echo "🔄 Ejecutando script remoto en los hosts listados..."
echo

# ────────────────────────────────
# Función: instalar dependencias locales
# ────────────────────────────────
instalar_dependencias() {
    local paquetes=("ssh" "sshpass" "scp")
    for pkg in "${paquetes[@]}"; do
        if ! command -v $pkg &>/dev/null; then
            echo "📦 Instalando $pkg..."
            if command -v apt-get &>/dev/null; then
                sudo apt-get update -y && sudo apt-get install -y $pkg
            elif command -v yum &>/dev/null; then
                sudo yum install -y $pkg
            else
                echo "⚠️ No se pudo instalar $pkg automáticamente. Instálalo manualmente."
                exit 1
            fi
        fi
    done
}
instalar_dependencias

# ────────────────────────────────
# Verificar archivo de IPs
# ────────────────────────────────
if [[ ! -f "$ARCHIVO_IPS" ]]; then
    echo "❌ No se encontró el archivo de IPs: $ARCHIVO_IPS"
    exit 1
fi

mapfile -t ips_array < "$ARCHIVO_IPS"

# ────────────────────────────────
# Procesar cada IP
# ────────────────────────────────
for ip in "${ips_array[@]}"; do
    ip=$(echo "$ip" | xargs)
    [[ -z "$ip" || "$ip" == \#* ]] && continue

    echo "➡️ Procesando IP: $ip"
    exito=false

    # 1. Probar conectividad con ping
    if ! ping -c 1 -W 2 "$ip" &>/dev/null; then
        echo "❌ $ip no responde al ping. Omitiendo..."
        echo "----------------------------------------"
        continue
    fi

    # 2. Limpiar posibles huellas previas de host key
    ssh-keygen -R "$ip" &>/dev/null

    # 3. Intento de conexión por clave SSH
    for intento in {1..2}; do
        echo "🔑 Intento $intento/2 con clave SSH..."
        if ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USUARIO@$ip" 'echo "Conexión con clave OK."' &>/dev/null; then
            echo "✅ Conectado con clave SSH."
            exito=true
            break
        else
            echo "❌ Falló intento con clave SSH."
        fi
    done

    # 4. Si falla, probar con contraseña (si fue ingresada)
    if ! $exito && [[ -n "$SUDO_PASS" ]]; then
        for intento in {1..3}; do
            echo "🔐 Intento $intento/3 con contraseña..."
            sshpass -p "$SUDO_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USUARIO@$ip" 'echo "Conexión con contraseña OK."' &>/dev/null
            if [[ $? -eq 0 ]]; then
                echo "✅ Conectado con contraseña."
                exito=true
                break
            else
                echo "❌ Falló intento con contraseña."
            fi
        done
    fi

    # 5. Si hubo éxito, copiar y ejecutar script remoto
    if $exito; then
        echo "📤 Copiando script remoto a $ip..."
        if [[ -n "$SUDO_PASS" ]]; then
            sshpass -p "$SUDO_PASS" scp -o StrictHostKeyChecking=no "$SCRIPT_REMOTO" "$USUARIO@$ip:/tmp/script_remoto.sh"
        else
            scp -o StrictHostKeyChecking=no "$SCRIPT_REMOTO" "$USUARIO@$ip:/tmp/script_remoto.sh"
        fi

        echo "🚀 Ejecutando script remoto en $ip..."
        if [[ -n "$SUDO_PASS" ]]; then
            sshpass -p "$SUDO_PASS" ssh -tt -o StrictHostKeyChecking=no "$USUARIO@$ip" "echo '$SUDO_PASS' | sudo -S bash /tmp/script_remoto.sh"
        else
            ssh -tt -o StrictHostKeyChecking=no "$USUARIO@$ip" "bash /tmp/script_remoto.sh"
        fi

        echo "🧹 Limpiando archivo temporal..."
        ssh -o StrictHostKeyChecking=no "$USUARIO@$ip" "rm -f /tmp/script_remoto.sh"

        echo "🏁 Script finalizado en $ip."
        echo "----------------------------------------"
    else
        echo "⚠️ No se pudo conectar con $ip. Se omite."
        echo "----------------------------------------"
    fi
done

echo "✅ Todos los procesos finalizados."
read -p "Presione Enter para salir..."
