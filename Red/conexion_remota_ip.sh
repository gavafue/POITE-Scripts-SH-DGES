#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Distribuir y ejecutar script remoto vía SSH a las IPs registradas
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📤 DISTRIBUCIÓN REMOTA POR IP (SSH)" "Ejecuta tareas automatizadas masivas en las computadoras del aula"

if [[ ! -f "$ARCHIVO_IPS" ]] || [[ ! -s "$ARCHIVO_IPS" ]]; then
    imprimir_error "No se encontraron IPs en $ARCHIVO_IPS"
    imprimir_info "Utilice primero la opción 'Registrar IP' para agregar equipos del laboratorio."
    pausar
    exit 1
fi

if [[ ! -f "$SCRIPT_REMOTO" ]]; then
    imprimir_error "No se encontró el script remoto a distribuir en: $SCRIPT_REMOTO"
    pausar
    exit 1
fi

echo -e "Script a distribuir: ${CYAN}$SCRIPT_REMOTO${RESET}"
echo -e "Lista de IPs destino: ${CYAN}$ARCHIVO_IPS${RESET}"
echo
nl -ba "$ARCHIVO_IPS"
echo

read -p "👤 Ingrese el nombre del usuario en los equipos remotos (ej: alumno / ceibal): " USUARIO
read -s -p "🔐 Ingrese la contraseña de ese usuario (dejar en blanco si usa clave SSH pública): " SUDO_PASS
echo
echo

# Función para verificar/instalar herramientas locales
for pkg in ssh sshpass scp ping; do
    if ! command -v "$pkg" &>/dev/null; then
        echo -e "${YELLOW}Instalando herramienta requerida localmente: $pkg...${RESET}"
        sudo apt update && sudo apt install -y "$pkg" || true
    fi
done

echo -e "${BOLD}Iniciando ciclo de distribución remota...${RESET}"
echo "----------------------------------------------------------------------"

TOTAL=0
EXITOSOS=0
FALLIDOS=0

while IFS= read -r ip || [[ -n "$ip" ]]; do
    ip=$(echo "$ip" | xargs)
    [[ -z "$ip" || "$ip" =~ ^# ]] && continue
    ((TOTAL++))

    echo -e "➡️  ${BOLD}Procesando equipo en $ip...${RESET}"
    
    # 1. Ping previo
    if ! ping -c 1 -W 2 "$ip" &>/dev/null; then
        imprimir_error "$ip no responde a ping (apagado o fuera de red)."
        ((FALLIDOS++))
        continue
    fi

    # 2. Limpiar huella antigua de host key si hubo reinstalación
    ssh-keygen -R "$ip" &>/dev/null || true

    # 3. Transferir script
    transferencia_ok=false
    if [[ -n "$SUDO_PASS" ]]; then
        if sshpass -p "$SUDO_PASS" scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$SCRIPT_REMOTO" "$USUARIO@$ip:/tmp/script_remoto.sh" &>/dev/null; then
            transferencia_ok=true
        fi
    else
        if scp -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$SCRIPT_REMOTO" "$USUARIO@$ip:/tmp/script_remoto.sh" &>/dev/null; then
            transferencia_ok=true
        fi
    fi

    if [[ "$transferencia_ok" = false ]]; then
        imprimir_error "Fallo al conectar o copiar script a $USUARIO@$ip."
        ((FALLIDOS++))
        continue
    fi

    # 4. Ejecutar script remoto
    echo -e "${CYAN}🚀 Ejecutando script en $ip...${RESET}"
    if [[ -n "$SUDO_PASS" ]]; then
        sshpass -p "$SUDO_PASS" ssh -o StrictHostKeyChecking=no "$USUARIO@$ip" "chmod +x /tmp/script_remoto.sh && PASSWORD='$SUDO_PASS' bash /tmp/script_remoto.sh && rm -f /tmp/script_remoto.sh"
    else
        ssh -o BatchMode=yes -o StrictHostKeyChecking=no "$USUARIO@$ip" "chmod +x /tmp/script_remoto.sh && bash /tmp/script_remoto.sh && rm -f /tmp/script_remoto.sh"
    fi

    imprimir_exito "Ejecución finalizada con éxito en $ip."
    ((EXITOSOS++))
    echo "----------------------------------------------------------------------"
done < "$ARCHIVO_IPS"

echo
echo -e "${BOLD}Resumen de distribución:${RESET}"
echo -e "  Total equipos: $TOTAL | ${GREEN}Exitosos: $EXITOSOS${RESET} | ${RED}Fallidos: $FALLIDOS${RESET}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ejecución remota IP completada. Total: $TOTAL, Éxitos: $EXITOSOS, Fallos: $FALLIDOS" >> "$ARCHIVO_LOG" 2>/dev/null || true

pausar
