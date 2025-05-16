#!/bin/bash

set -euo pipefail

ARCHIVO_MACS="./RegistrarIP/macs.txt"
SCRIPT_LOCAL="./RegistrarIP/remoto.sh"
USUARIO="gabriel"
PASSWORD="1234"
RUTA_REMOTA="/tmp/script_remoto.sh"
INTENTOS=3
TIMEOUT=5

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

pausa() {
  read -rp "Presione Enter para volver atrás..."
}

instalar_si_falta() {
  local herramienta=$1
  if ! command -v "$herramienta" &>/dev/null; then
    echo -e "${YELLOW}🛠️  Instalando '$herramienta'...${RESET}"
    sudo apt-get update -qq
    sudo apt-get install -y "$herramienta"
    echo -e "${GREEN}✅ '$herramienta' instalado.${RESET}"
  else
    echo -e "${CYAN}✔️ '$herramienta' ya está instalado.${RESET}"
  fi
}

for herramienta in arp-scan sshpass ssh scp; do
  instalar_si_falta "$herramienta"
done

buscar_ip_por_mac() {
  local mac="$1"
  arp-scan -l | grep -i "$mac" | awk '{print $1}'
}

conectar_y_enviar() {
  local ip="$1"

  echo -e "${YELLOW}➡️  Procesando IP: $ip (asociada a MAC objetivo)${RESET}"

  for intento in $(seq 1 $INTENTOS); do
    echo -e "${CYAN}🔐 Intento $intento/$INTENTOS con contraseña SSH...${RESET}"
    if sshpass -p "$PASSWORD" ssh -o ConnectTimeout=$TIMEOUT -o StrictHostKeyChecking=no "$USUARIO@$ip" "echo ok" &>/dev/null; then
      echo -e "${GREEN}✅ Conectado a $ip.${RESET}"
      if sshpass -p "$PASSWORD" scp -o ConnectTimeout=$TIMEOUT -o StrictHostKeyChecking=no "$SCRIPT_LOCAL" "$USUARIO@$ip:$RUTA_REMOTA" &>/dev/null; then
        if sshpass -p "$PASSWORD" ssh -o ConnectTimeout=$TIMEOUT -o StrictHostKeyChecking=no "$USUARIO@$ip" "bash $RUTA_REMOTA"; then
          echo -e "${GREEN}✔️ Script ejecutado en $ip correctamente.${RESET}"
          return 0
        else
          echo -e "${RED}❌ Fallo al ejecutar script en $ip.${RESET}"
          pausa
        fi
      else
        echo -e "${RED}❌ Fallo al copiar script a $ip.${RESET}"
        pausa
      fi
    else
      echo -e "${YELLOW}❌ No se pudo conectar a $ip (intento $intento).${RESET}"
      pausa
    fi
  done

  echo -e "${RED}❌ No se pudo establecer conexión con $ip tras $INTENTOS intentos.${RESET}"
  pausa
}

echo -e "${CYAN}📡 Escaneando red y ejecutando script en MACs listadas en '$ARCHIVO_MACS'...${RESET}"

while IFS= read -r mac || [[ -n "$mac" ]]; do
  mac=$(echo "$mac" | tr '[:upper:]' '[:lower:]' | xargs)
  [[ -z "$mac" ]] && continue

  echo -e "${CYAN}🔍 Buscando IP para MAC: $mac${RESET}"
  ip=$(buscar_ip_por_mac "$mac")

  if [[ -n "$ip" ]]; then
    echo -e "${GREEN}🔗 MAC $mac asociada a IP $ip${RESET}"
    conectar_y_enviar "$ip"
  else
    echo -e "${RED}❌ No se encontró IP para MAC $mac${RESET}"
    pausa
  fi

  echo -e "${CYAN}----------------------------------------${RESET}"
done < "$ARCHIVO_MACS"

echo -e "${GREEN}🏁 Proceso finalizado para todas las MAC.${RESET}"
pausa
#Fin del script
# Este script busca direcciones IP asociadas a direcciones MAC en un archivo.
# Si encuentra una IP, intenta conectarse a ella usando SSH y ejecutar un script remoto.
# Requiere herramientas como arp-scan, sshpass, ssh y scp.
# Se recomienda ejecutar este script con permisos de superusuario para un funcionamiento óptimo.
# Asegúrate de que el archivo de MACs y el script remoto existan y sean accesibles.