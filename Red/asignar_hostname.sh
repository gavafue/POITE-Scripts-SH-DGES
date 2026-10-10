#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Asignación Asistida de Hostnames a Equipos (Local, Remoto y Secuencial en Lote)
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🏷️ ASIGNAR HOSTNAMES A EQUIPOS" "Estandarice nombres de red en el aula (ej: lab1-pc01, lab1-pc02)"

aplicar_hostname_local() {
    local nuevo_nombre="$1"
    asegurar_root || return 1

    echo -e "${CYAN}• Estableciendo nuevo hostname con hostnamectl...${RESET}"
    sudo hostnamectl set-hostname "$nuevo_nombre"

    echo -e "${CYAN}• Actualizando resolución en /etc/hosts...${RESET}"
    if grep -q "^127\.0\.1\.1" /etc/hosts; then
        sudo sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t$nuevo_nombre/" /etc/hosts
    else
        echo -e "127.0.1.1\t$nuevo_nombre" | sudo tee -a /etc/hosts >/dev/null
    fi

    # Asegurar línea localhost
    if ! grep -q "127\.0\.0\.1" /etc/hosts; then
        echo -e "127.0.0.1\tlocalhost" | sudo tee -a /etc/hosts >/dev/null
    fi

    imprimir_exito "Hostname local cambiado exitosamente a: ${BOLD}${GREEN}$(hostname)${RESET}"
}

aplicar_hostname_remoto() {
    local ip="$1"
    local usuario="$2"
    local nuevo_nombre="$3"
    local puerto="${4:-22}"

    echo -e "${CYAN}Conectando por SSH a $usuario@$ip:$puerto para asignar '$nuevo_nombre'...${RESET}"

    # Comando a ejecutar remotamente
    local cmd="sudo hostnamectl set-hostname '$nuevo_nombre' && if grep -q '^127\.0\.1\.1' /etc/hosts; then sudo sed -i 's/^127\.0\.1\.1.*/127.0.1.1\t$nuevo_nombre/' /etc/hosts; else echo -e '127.0.1.1\t$nuevo_nombre' | sudo tee -a /etc/hosts >/dev/null; fi"

    if ssh -p "$puerto" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$usuario@$ip" "$cmd" 2>/dev/null; then
        local comprobado
        comprobado=$(ssh -p "$puerto" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$usuario@$ip" "hostname" 2>/dev/null || true)
        if [[ "$comprobado" == "$nuevo_nombre" ]]; then
            imprimir_exito "Equipo $ip renombrado a '$nuevo_nombre' con éxito."
            return 0
        fi
    fi

    imprimir_error "No se pudo actualizar el hostname en $ip. Verifique acceso SSH y permisos sudo."
    return 1
}

echo -e "Seleccione la modalidad de asignación:"
echo -e "  ${GREEN}1)${RESET} 💻 Asignar hostname a ESTA computadora local"
echo -e "  ${GREEN}2)${RESET} 🌐 Asignar hostname a una computadora REMOTA (por SSH)"
echo -e "  ${GREEN}3)${RESET} 📚 Asignación SECUENCIAL EN LOTE para todo el laboratorio (ej: lab1-pc01... lab1-pc20)"
echo -e "  ${RED}0)${RESET} 🔙 Cancelar y volver"
echo
echo -ne "${BOLD}Seleccione una opción [0-3]: ${RESET}"
read -r opcion

case "$opcion" in
    1)
        ACTUAL=$(hostname)
        echo
        echo -e "Hostname actual de este equipo: ${BOLD}${YELLOW}$ACTUAL${RESET}"
        echo -ne "${CYAN}Ingrese el nuevo nombre para este equipo (ej: lab1-pc01): ${RESET}"
        read -r nuevo

        if ! validar_formato_hostname "$nuevo"; then
            imprimir_error "Nombre de host no válido. Solo se permiten letras minúsculas, números y guiones (sin espacios ni símbolos)."
            pausar
            exit 1
        fi

        aplicar_hostname_local "$nuevo"
        ;;

    2)
        echo
        if [[ -f "$ARCHIVO_IPS" ]] && [[ -s "$ARCHIVO_IPS" ]]; then
            echo -e "${BOLD}IPs registradas disponibles en $ARCHIVO_IPS:${RESET}"
            nl -w2 -s") " "$ARCHIVO_IPS"
            echo
        fi

        echo -ne "${CYAN}Ingrese la dirección IP del equipo remoto: ${RESET}"
        read -r ip_remota

        if ! ping -c 1 -W 2 "$ip_remota" >/dev/null 2>&1; then
            imprimir_error "El equipo $ip_remota no responde a ping en la red."
            pausar
            exit 1
        fi

        echo -ne "${CYAN}Usuario SSH en el equipo remoto [Enter para '$(whoami)']: ${RESET}"
        read -r user_ssh
        USER_REMOTO="${user_ssh:-$(whoami)}"

        echo -ne "${CYAN}Nuevo hostname a asignar (ej: lab1-pc05): ${RESET}"
        read -r nuevo_remoto

        if ! validar_formato_hostname "$nuevo_remoto"; then
            imprimir_error "Formato de nombre inválido."
            pausar
            exit 1
        fi

        aplicar_hostname_remoto "$ip_remota" "$USER_REMOTO" "$nuevo_remoto"
        ;;

    3)
        echo
        echo -e "${BOLD}Asignación masiva secuencial para laboratorio completo:${RESET}"
        echo "Este proceso recorrerá un listado de IPs y renombrará secuencialmente cada equipo."
        echo

        if [[ ! -f "$ARCHIVO_IPS" ]] || [[ ! -s "$ARCHIVO_IPS" ]]; then
            imprimir_aviso "No se encontró el archivo de IPs '$ARCHIVO_IPS'. Se sugiere escanear la red primero."
            echo -ne "¿Desea ingresar una lista manual de IPs separadas por espacio? (s/N): "
            read -r resp_manual
            if [[ "$resp_manual" =~ ^[sS]$ ]]; then
                echo -ne "Ingrese las IPs: "
                read -r -a LISTA_IPS
            else
                exit 0
            fi
        else
            echo -e "Usando IPs desde: ${CYAN}$ARCHIVO_IPS${RESET} ($(wc -l < "$ARCHIVO_IPS") equipos registrados)"
            mapfile -t LISTA_IPS < "$ARCHIVO_IPS"
        fi

        if [[ ${#LISTA_IPS[@]} -eq 0 ]]; then
            imprimir_error "No hay IPs para procesar."
            pausar
            exit 1
        fi

        echo
        echo -ne "${CYAN}Prefijo del laboratorio (ej: lab1-pc / sala2-pc): [lab1-pc]: ${RESET}"
        read -r prefijo_in
        PREFIJO="${prefijo_in:-lab1-pc}"

        echo -ne "${CYAN}Número inicial para la secuencia [Enter para 1]: ${RESET}"
        read -r inicio_in
        NUMERO_INICIAL="${inicio_in:-1}"

        echo -ne "${CYAN}Usuario SSH para conectar a los equipos [Enter para '$(whoami)']: ${RESET}"
        read -r user_in
        USER_SSH="${user_in:-$(whoami)}"

        echo
        echo -e "${YELLOW}¿Confirmar asignación secuencial a ${#LISTA_IPS[@]} equipos comenzando en '${PREFIJO}$(printf "%02d" "$NUMERO_INICIAL")'? (S/n): ${RESET}"
        read -r confirm
        if [[ -n "$confirm" && ! "$confirm" =~ ^[sS]$ ]]; then
            imprimir_info "Operación cancelada."
            pausar
            exit 0
        fi

        echo
        echo -e "${BOLD}Iniciando asignación masiva de hostnames...${RESET}"
        echo "----------------------------------------------------------------------"

        IDX=$NUMERO_INICIAL
        EXITOSOS=0
        FALLIDOS=0
        declare -A MAPEO_ASIGNADOS

        for ip in "${LISTA_IPS[@]}"; do
            # Limpiar espacios
            ip=$(echo "$ip" | tr -d '\r\n' | xargs)
            [[ -z "$ip" || "$ip" =~ ^# ]] && continue

            NOMBRE_OBJETIVO=$(printf "%s%02d" "$PREFIJO" "$IDX")
            printf "• [%s] Conectando a %-15s -> Hostname %-15s ... " "$IDX" "$ip" "$NOMBRE_OBJETIVO"

            # Si es el host local
            if [[ "$ip" == "$(obtener_ip_local)" ]]; then
                if aplicar_hostname_local "$NOMBRE_OBJETIVO" >/dev/null 2>&1; then
                    echo -e "${GREEN}OK (Local)${RESET}"
                    MAPEO_ASIGNADOS["$NOMBRE_OBJETIVO"]="$ip"
                    ((EXITOSOS++))
                else
                    echo -e "${RED}FALLÓ (Local)${RESET}"
                    ((FALLIDOS++))
                fi
            else
                if aplicar_hostname_remoto "$ip" "$USER_SSH" "$NOMBRE_OBJETIVO" 22 >/dev/null 2>&1; then
                    echo -e "${GREEN}OK${RESET}"
                    MAPEO_ASIGNADOS["$NOMBRE_OBJETIVO"]="$ip"
                    ((EXITOSOS++))
                else
                    echo -e "${RED}ERROR SSH${RESET}"
                    ((FALLIDOS++))
                fi
            fi

            ((IDX++))
        done

        echo "----------------------------------------------------------------------"
        echo -e "${BOLD}Resumen:${RESET} Exitosos: ${GREEN}$EXITOSOS${RESET} | Fallidos: ${RED}$FALLIDOS${RESET}"

        # Actualizar inventario de Ansible si hubo éxitos
        if [[ $EXITOSOS -gt 0 ]]; then
            INVENTARIO_INI="$DIR_DATOS/inventario_ansible.ini"
            echo
            echo -e "${CYAN}Actualizando inventario de Ansible en $INVENTARIO_INI...${RESET}"
            {
                echo "# =============================================================================="
                echo "# INVENTARIO DE ANSIBLE - LABORATORIO DE INFORMÁTICA"
                echo "# Generado automáticamente tras asignación de hostnames: $(date '+%Y-%m-%d %H:%M:%S')"
                echo "# =============================================================================="
                echo
                echo "[laboratorio]"
                for h in "${!MAPEO_ASIGNADOS[@]}"; do
                    echo "$h ansible_host=${MAPEO_ASIGNADOS[$h]}"
                done
                echo
                echo "[laboratorio:vars]"
                echo "ansible_user=$USER_SSH"
                echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
            } > "$INVENTARIO_INI"
            imprimir_exito "Inventario de Ansible actualizado con los nuevos hostnames."
        fi
        ;;

    0)
        imprimir_info "Operación cancelada."
        ;;
    *)
        imprimir_error "Opción no válida."
        ;;
esac

pausar
