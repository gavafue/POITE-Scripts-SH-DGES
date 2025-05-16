#!/bin/bash

#======================= CONFIGURACIÓN =======================#
REMOTE_SCRIPT="./RegistrarIP/remoto.sh"
MAC_FILE="./RegistrarIP/macs.txt"
#=============================================================#

#------------ Función para instalar dependencias ------------#
instalar_si_falta() {
    comando=$1
    paquete=$2
    if ! command -v "$comando" &>/dev/null; then
        echo "🔧 Instalando $paquete..."
        sudo apt update && sudo apt install -y "$paquete"
        if ! command -v "$comando" &>/dev/null; then
            echo "❌ No se pudo instalar $paquete. Abortando."
            exit 1
        fi
    fi
}

#------------------- Instalar herramientas ------------------#
instalar_si_falta "ipcalc" "ipcalc"
instalar_si_falta "nmap" "nmap"
instalar_si_falta "arp-scan" "arp-scan"
instalar_si_falta "arp" "net-tools"
instalar_si_falta "ssh" "openssh-client"
instalar_si_falta "sshpass" "sshpass"

#------------------- Leer MACs desde archivo ----------------#
if [[ ! -f "$MAC_FILE" ]]; then
    echo "❌ Archivo de MACs no encontrado: $MAC_FILE"
    exit 1
fi

mapfile -t MACS < <(grep -iE '([0-9a-f]{2}:){5}[0-9a-f]{2}' "$MAC_FILE")

if [[ ${#MACS[@]} -eq 0 ]]; then
    echo "❌ El archivo $MAC_FILE no contiene MACs válidas."
    exit 1
fi

#------------------- Obtener interfaz activa ----------------#
interfaz=$(ip route | awk '/default/ {print $5}' | head -n1)

if [[ -z "$interfaz" || "$interfaz" == "lo" ]]; then
    echo "❌ No se detectó una interfaz activa válida."
    exit 1
fi

echo "🌐 Usando interfaz de red: $interfaz"

#------------------- Obtener MAC e IP local ------------------#
mac_local=$(cat /sys/class/net/"$interfaz"/address | tr '[:upper:]' '[:lower:]')
ip_local=$(ip -4 addr show "$interfaz" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

#------------------- Obtener subred -------------------------#
ip_cidr=$(ip -4 addr show "$interfaz" | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')
subred=$(ipcalc -n "$ip_cidr" | grep -oP 'Network:\s+\K\S+')

if [[ -z "$subred" ]]; then
    echo "❌ No se pudo determinar la subred."
    exit 1
fi

echo "📡 Subred detectada: $subred"

#------------------- Escaneo de red -------------------------#
echo "🔍 Escaneando red con nmap..."
sudo nmap -sn "$subred" >/dev/null

echo "🔍 Obteniendo tabla ARP..."
arp_output=$(arp -an)

echo "🔍 Escaneando red con arp-scan..."
arp_scan_output=$(sudo arp-scan --interface="$interfaz" "$subred")

#------------------- Credenciales SSH ------------------------#
read -p "👤 Usuario remoto: " usuario
read -s -p "🔐 Contraseña SSH (dejar vacío si se usa clave): " clave
echo

#------------------- Buscar y ejecutar -----------------------#
for mac in "${MACS[@]}"; do
    mac_normalizada=$(echo "$mac" | tr '[:upper:]' '[:lower:]')
    echo "🔎 Procesando MAC: $mac_normalizada"
    ip=""

    # Si es la MAC local, usar IP local
    if [[ "$mac_normalizada" == "$mac_local" ]]; then
        ip="$ip_local"
        echo "🏠 MAC corresponde al equipo local. IP: $ip"
    else
        # Buscar IP en las distintas fuentes
        ip=$(echo "$arp_output" | awk -v mac="$mac_normalizada" 'tolower($4)==mac {gsub(/[()]/, "", $2); print $2}')
        [[ -z "$ip" ]] && ip=$(ip neigh | awk -v mac="$mac_normalizada" 'tolower($5)==mac {print $1}')
        [[ -z "$ip" ]] && ip=$(echo "$arp_scan_output" | awk -v mac="$mac_normalizada" 'tolower($2)==mac {print $1}')
    fi

    if [[ -z "$ip" || ! "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "❌ IP inválida o no encontrada para MAC $mac"
        continue
    fi

    echo "➡️ IP utilizada: $ip"
    exito=false

    # Intento con clave pública
    for intento in {1..3}; do
        echo "🔑 Intento $intento/3 con clave SSH..."
        if ssh -o BatchMode=yes -o ConnectTimeout=5 "$usuario@$ip" 'echo "Conexión con clave OK."' &>/dev/null; then
            echo "✅ Conectado con clave SSH."
            exito=true
            break
        else
            echo "❌ Falló intento con clave SSH."
        fi
    done

    # Si no funcionó la clave, intento con contraseña
    if ! $exito && [[ -n "$clave" ]]; then
        for intento in {1..3}; do
            echo "🔐 Intento $intento/3 con contraseña..."
            sshpass -p "$clave" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$usuario@$ip" 'echo "Conexión con contraseña OK."' &>/dev/null
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
        sshpass -p "$clave" scp -o StrictHostKeyChecking=no "$REMOTE_SCRIPT" "$usuario@$ip:/tmp/script_remoto.sh" &>/dev/null

        echo "🚀 Ejecutando script remoto en $ip..."
        sshpass -p "$clave" ssh -tt -o StrictHostKeyChecking=no "$usuario@$ip" "export PASSWORD='$clave'; bash /tmp/script_remoto.sh"

        echo "🧹 Limpiando script remoto..."
        sshpass -p "$clave" ssh -o StrictHostKeyChecking=no "$usuario@$ip" "rm /tmp/script_remoto.sh"

        echo "🏁 Script finalizado en $ip."
    else
        echo "⚠️ No se pudo conectar a $ip. Se omite."
    fi

    echo "---------------------------------------------"
done

echo "✅ Proceso finalizado."
read -p "Presione Enter para salir..."

# Fin del script
# Este script permite la conexión remota a equipos de red utilizando SSH.
# Se encarga de instalar las herramientas necesarias, leer un archivo de MACs,
# escanear la red y ejecutar un script remoto en los equipos encontrados.
# Asegúrese de tener los permisos necesarios para realizar las acciones solicitadas.