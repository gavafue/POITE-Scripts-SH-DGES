#!/bin/bash

set -euo pipefail

ARCHIVO_IPS="./RegistrarIP/ips.txt"
SCRIPT_LOCAL="./RegistrarIP/remoto.sh"
USUARIO="liceo"
PASSWORD="passdoc14"
RUTA_REMOTA="/tmp/script_remoto.sh"
INTENTOS=3
TIMEOUT=5
LOG_FILE="./RegistrarIP/registro_ejecuciones.log"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

log() {
  echo -e "$1"
  echo -e "$(date +'%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

# Validar existencia y permisos de archivos
for archivo in "$ARCHIVO_IPS" "$SCRIPT_LOCAL"; do
  if [[ ! -f "$archivo" ]]; then
    log "${RED}❌ Archivo '$archivo' no encontrado.${RESET}"
    read -p "Presione Enter para volver al menú..."
    exit 1
  fi
  if [[ ! -r "$archivo" ]]; then
    log "${RED}❌ Sin permisos de lectura para '$archivo'.${RESET}"
    read -p "Presione Enter para volver al menú..."
    exit 1
  fi
done

# Verificar sshpass
if ! command -v sshpass &> /dev/null; then
  log "${YELLOW}⚠️  'sshpass' no está instalado. Instalando automáticamente...${RESET}"
  sudo apt update && sudo apt install -y sshpass
fi

# Validar IP (IPv4 básica)
es_ip_valida() {
  local ip="$1"
  [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  IFS='.' read -r -a octetos <<< "$ip"
  for octeto in "${octetos[@]}"; do
    ((octeto >= 0 && octeto <= 255)) || return 1
  done
  return 0
}

# Conexión con clave SSH
intentar_ssh_clave() {
  ssh -o ConnectTimeout=$TIMEOUT -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$USUARIO@$1" "echo ok" &>/dev/null
}

# Conexión con contraseña SSH
intentar_ssh_pass() {
  sshpass -p "$PASSWORD" ssh -o ConnectTimeout=$TIMEOUT -o StrictHostKeyChecking=no "$USUARIO@$1" "echo ok" &>/dev/null
}

# Copiar el script remoto
copiar_script() {
  local ip="$1" metodo="$2"
  if [[ "$metodo" == "clave" ]]; then
    scp -o ConnectTimeout=$TIMEOUT "$SCRIPT_LOCAL" "$USUARIO@$ip:$RUTA_REMOTA" &>/dev/null
  else
    sshpass -p "$PASSWORD" scp -o ConnectTimeout=$TIMEOUT -o StrictHostKeyChecking=no "$SCRIPT_LOCAL" "$USUARIO@$ip:$RUTA_REMOTA" &>/dev/null
  fi
}

# Ejecutar el script remoto
ejecutar_script() {
  local ip="$1" metodo="$2"
  if [[ "$metodo" == "clave" ]]; then
    ssh -o ConnectTimeout=$TIMEOUT "$USUARIO@$ip" "bash $RUTA_REMOTA"
  else
    sshpass -p "$PASSWORD" ssh -o ConnectTimeout=$TIMEOUT -o StrictHostKeyChecking=no "$USUARIO@$ip" "bash $RUTA_REMOTA"
  fi
}

# Inicio
echo -e "${CYAN}🔄 Ejecutando script en los hosts listados en '$ARCHIVO_IPS'...${RESET}"
echo -e "$(date)\n----------------------------------------\n" >> "$LOG_FILE"

while IFS= read -r ip || [[ -n "$ip" ]]; do
  ip=$(echo "$ip" | xargs)
  [[ -z "$ip" ]] && continue

  log "${YELLOW}➡️  Procesando IP: $ip${RESET}"

  if ! es_ip_valida "$ip"; then
    log "${RED}❌ IP inválida: '$ip'. Se omite.${RESET}"
    continue
  fi

  conectado=0

  # Conexión por clave SSH
  for intento in $(seq 1 $INTENTOS); do
    log "${CYAN}🔑 Intento $intento/$INTENTOS con clave SSH...${RESET}"
    if intentar_ssh_clave "$ip"; then
      log "${GREEN}✅ Conectado a $ip con clave SSH.${RESET}"
      if copiar_script "$ip" "clave"; then
        if ejecutar_script "$ip" "clave"; then
          log "${GREEN}✔️ Script ejecutado correctamente en $ip con clave SSH.${RESET}"
          conectado=1
          break
        else
          log "${RED}❌ Error al ejecutar script en $ip con clave SSH.${RESET}"
        fi
      else
        log "${RED}❌ Error al copiar script a $ip con clave SSH.${RESET}"
      fi
    else
      log "${YELLOW}❌ No se pudo conectar con clave SSH en intento $intento.${RESET}"
    fi
  done

  # Conexión por contraseña
  if [[ $conectado -eq 0 && $(command -v sshpass) ]]; then
    for intento in $(seq 1 $INTENTOS); do
      log "${CYAN}🔐 Intento $intento/$INTENTOS con contraseña...${RESET}"
      if intentar_ssh_pass "$ip"; then
        log "${GREEN}✅ Conectado a $ip con contraseña.${RESET}"
        if copiar_script "$ip" "pass"; then
          if ejecutar_script "$ip" "pass"; then
            log "${GREEN}✔️ Script ejecutado correctamente en $ip con contraseña.${RESET}"
            conectado=1
            break
          else
            log "${RED}❌ Error al ejecutar script en $ip con contraseña.${RESET}"
          fi
        else
          log "${RED}❌ Error al copiar script a $ip con contraseña.${RESET}"
        fi
      else
        log "${YELLOW}❌ No se pudo conectar con contraseña en intento $intento.${RESET}"
      fi
    done
  fi

  [[ $conectado -eq 0 ]] && log "${RED}❌ Fallo total de conexión con $ip.${RESET}"

  echo -e "${CYAN}----------------------------------------${RESET}"
done < "$ARCHIVO_IPS"

echo -e "${GREEN}🏁 Script finalizado en todas las máquinas.${RESET}"
read -p "Presione Enter para volver al menú..."
