#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Motor de Despliegue Remoto del Perfil Maestro (Alternativa a Clonación)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

ARCHIVO_PERFIL="$DIR_DATOS/perfil_maestro.conf"
SCRIPT_AUTONOMO="$DIR_DATOS/replicar_perfil_autonomo.sh"
INVENTARIO_INI="$DIR_DATOS/inventario_ansible.ini"
PLAYBOOK_AULA="$BASE_DIR/ansible/playbooks/desplegar_perfil_aula.yml"

imprimir_encabezado "🚀 DESPLEGAR PERFIL MAESTRO EN PCs LIMPIAS" "Aprovisiona software, usuarios y ajustes a través de la red sin clonar discos"

if [[ ! -f "$ARCHIVO_PERFIL" ]] || [[ ! -f "$SCRIPT_AUTONOMO" ]]; then
    imprimir_aviso "No se encontró un Perfil Maestro capturado previamente."
    echo -e "Es necesario capturar primero el perfil desde la máquina de referencia."
    echo -ne "¿Desea capturar el perfil ahora? (S/n): "
    read -r r_cap
    if [[ -z "$r_cap" || "$r_cap" =~ ^[sS]$ ]]; then
        bash "$BASE_DIR/ReplicacionAula/capturar_perfil_maestro.sh"
    else
        exit 0
    fi
fi

# shellcheck disable=SC1090
source "$ARCHIVO_PERFIL"

echo -e "Perfil a desplegar: ${BOLD}${CYAN}$NOMBRE_PERFIL${RESET} (Capturado: $FECHA_CAPTURA)"
echo -e "Paquetes a instalar: ${GREEN}$PAQUETES_EDUCATIVOS${RESET}"
echo

# 1. Selección de computadoras destino
echo -e "${BOLD}1. Seleccione las computadoras limpias a aprovisionar:${RESET}"
echo -e "  ${GREEN}1)${RESET} Todas las computadoras registradas en el inventario ($ARCHIVO_IPS)"
echo -e "  ${GREEN}2)${RESET} Una sola computadora específica por IP (para probar)"
echo -e "  ${GREEN}3)${RESET} Ingresar lista manual de IPs"
echo -e "  ${RED}0)${RESET} Cancelar"
echo -ne "${BOLD}Seleccione una opción [0-3]: ${RESET}"
read -r opt_destinos

LISTA_DESTINOS=()
case "$opt_destinos" in
    1)
        if [[ ! -f "$ARCHIVO_IPS" ]] || [[ ! -s "$ARCHIVO_IPS" ]]; then
            imprimir_error "El archivo de IPs '$ARCHIVO_IPS' está vacío. Mapee la red primero."
            pausar
            exit 1
        fi
        mapfile -t LISTA_DESTINOS < "$ARCHIVO_IPS"
        ;;
    2)
        echo -ne "Ingrese la dirección IP del equipo de prueba: "
        read -r ip_prueba
        LISTA_DESTINOS=("$ip_prueba")
        ;;
    3)
        echo -ne "Ingrese las IPs separadas por espacio: "
        read -r -a LISTA_DESTINOS
        ;;
    0)
        exit 0
        ;;
    *)
        imprimir_error "Opción no válida."
        exit 1
        ;;
esac

# Filtrar líneas vacías
IPS_FINALES=()
for ip in "${LISTA_DESTINOS[@]}"; do
    ip=$(echo "$ip" | tr -d '\r\n' | xargs)
    [[ -n "$ip" && ! "$ip" =~ ^# ]] && IPS_FINALES+=("$ip")
done

if [[ ${#IPS_FINALES[@]} -eq 0 ]]; then
    imprimir_error "No hay IPs válidas para desplegar."
    pausar
    exit 1
fi

echo
echo -e "Total de computadoras a aprovisionar: ${BOLD}${CYAN}${#IPS_FINALES[@]}${RESET}"

# 2. Configuración de credenciales de acceso SSH
echo
echo -ne "${CYAN}Usuario SSH para conectar a las máquinas [Enter para '$(whoami)']: ${RESET}"
read -r u_input
USER_SSH="${u_input:-$(whoami)}"

# 3. Renombrado secuencial de Hostnames
echo
echo -ne "¿Desea asignar automáticamente nombres secuenciales ($PREFIJO_HOSTNAME-01...) a cada equipo? [S/n]: "
read -r r_renombrar
RENOMBRAR_HOSTNAMES=true
NUM_INICIO=1
if [[ -z "$r_renombrar" || "$r_renombrar" =~ ^[sS]$ ]]; then
    echo -ne "Número inicial para la secuencia [Enter para 1]: "
    read -r in_num
    NUM_INICIO="${in_num:-1}"
else
    RENOMBRAR_HOSTNAMES=false
fi

# 4. Método de ejecución
METODO_ANSIBLE=false
if command -v ansible >/dev/null 2>&1 && [[ -f "$PLAYBOOK_AULA" ]]; then
    echo
    echo -e "${BOLD}Método de despliegue preferido:${RESET}"
    echo -e "  ${GREEN}1)${RESET} ⚡ Ansible (Paralelo masivo en todas las PCs simultáneamente - Recomendado)"
    echo -e "  ${GREEN}2)${RESET} 🔄 Bucle SSH nativo secuencial (Sin requerir Ansible)"
    echo -ne "${BOLD}Seleccione [1/2]: ${RESET}"
    read -r r_metodo
    if [[ "$r_metodo" == "1" || -z "$r_metodo" ]]; then
        METODO_ANSIBLE=true
    fi
fi

echo
echo -e "${YELLOW}======================================================================${RESET}"
echo -e "${BOLD}${YELLOW}⚠️  CONFIRMACIÓN DE REPLICACIÓN DE LABORATORIO${RESET}"
echo -e "${YELLOW}======================================================================${RESET}"
echo -e "Se aplicará el perfil '${CYAN}$NOMBRE_PERFIL${RESET}' a ${BOLD}${#IPS_FINALES[@]} computadoras${RESET} vía ${USER_SSH}."
echo -ne "¿Está seguro de iniciar el despliegue? (S/n): "
read -r conf_despliegue
if [[ -n "$conf_despliegue" && ! "$conf_despliegue" =~ ^[sS]$ ]]; then
    imprimir_info "Despliegue cancelado."
    pausar
    exit 0
fi

echo
imprimir_info "Iniciando aprovisionamiento del aula..."
echo "----------------------------------------------------------------------"

# Si se usa Ansible
if [[ "$METODO_ANSIBLE" = true ]]; then
    # Actualizar inventario temporal de Ansible con las IPs seleccionadas
    TEMP_INV=$(mktemp)
    {
        echo "[laboratorio]"
        idx=$NUM_INICIO
        for ip in "${IPS_FINALES[@]}"; do
            if [[ "$RENOMBRAR_HOSTNAMES" = true ]]; then
                nom=$(printf "%s%02d" "$PREFIJO_HOSTNAME" "$idx")
                echo "$nom ansible_host=$ip"
                ((idx++))
            else
                echo "pc-$ip ansible_host=$ip"
            fi
        done
        echo
        echo "[laboratorio:vars]"
        echo "ansible_user=$USER_SSH"
        echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
    } > "$TEMP_INV"

    ANSIBLE_CONFIG="$BASE_DIR/ansible/ansible.cfg" ansible-playbook -i "$TEMP_INV" "$PLAYBOOK_AULA"
    rm -f "$TEMP_INV"
else
    # Ejecución por SSH nativo
    EXITOSOS=0
    FALLIDOS=0
    idx=$NUM_INICIO

    for ip in "${IPS_FINALES[@]}"; do
        if [[ "$RENOMBRAR_HOSTNAMES" = true ]]; then
            HNAME_NUEVO=$(printf "%s%02d" "$PREFIJO_HOSTNAME" "$idx")
        else
            HNAME_NUEVO=""
        fi

        printf "• [%s/%s] Desplegando en %-15s " "$idx" "${#IPS_FINALES[@]}" "$ip"
        if [[ -n "$HNAME_NUEVO" ]]; then
            printf "(%s) ... " "$HNAME_NUEVO"
        else
            printf "... "
        fi

        if ! ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
            echo -e "${RED}NO RESPONDE A PING${RESET}"
            ((FALLIDOS++))
            ((idx++))
            continue
        fi

        # 1. Renombrar hostname si corresponde
        if [[ -n "$HNAME_NUEVO" ]]; then
            ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER_SSH@$ip" \
                "sudo hostnamectl set-hostname '$HNAME_NUEVO' && sudo sed -i 's/^127\.0\.1\.1.*/127.0.1.1\t$HNAME_NUEVO/' /etc/hosts 2>/dev/null || true" >/dev/null 2>&1 || true
        fi

        # 2. Transferir y ejecutar el script de replicación
        if ssh -o ConnectTimeout=8 -o StrictHostKeyChecking=no "$USER_SSH@$ip" "sudo bash -s" < "$SCRIPT_AUTONOMO" >/dev/null 2>&1; then
            echo -e "${GREEN}APROVISIONADO CON ÉXITO${RESET}"
            ((EXITOSOS++))
        else
            echo -e "${RED}ERROR DE EJECUCIÓN SSH${RESET}"
            ((FALLIDOS++))
        fi

        ((idx++))
    done

    echo "----------------------------------------------------------------------"
    echo -e "${BOLD}Resumen Final:${RESET} Exitosos: ${GREEN}$EXITOSOS${RESET} | Fallidos: ${RED}$FALLIDOS${RESET}"
fi

echo
imprimir_exito "Proceso de replicación finalizado. Las computadoras cuentan ahora con el software, usuarios y ajustes del perfil maestro."
pausar
