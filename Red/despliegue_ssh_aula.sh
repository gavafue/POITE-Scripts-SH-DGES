#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Aprovisionamiento y Despliegue Automatizado de SSH en el Aula
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🚀 DESPLIEGUE AUTOMATIZADO DE SSH EN EL AULA" "Habilita SSH en múltiples computadoras sin instalarlas una por una"

asegurar_clave_docente() {
    local clave_pub=""
    for k in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub"; do
        if [[ -f "$k" ]]; then
            clave_pub=$(cat "$k")
            break
        fi
    done

    if [[ -z "$clave_pub" ]]; then
        echo -e "${YELLOW}ℹ️  No se detectó un par de claves SSH en su cuenta ($HOME/.ssh/).${RESET}"
        echo -e "${CYAN}Generando par de claves de alta seguridad (ED25519) para administrar el aula...${RESET}"
        mkdir -p "$HOME/.ssh"
        ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" -C "docente-poite@$(hostname)" >/dev/null 2>&1
        clave_pub=$(cat "$HOME/.ssh/id_ed25519.pub")
        imprimir_exito "Clave generada en $HOME/.ssh/id_ed25519.pub."
    fi

    echo "$clave_pub"
}

IP_DOCENTE=$(obtener_ip_local)

echo -e "En GNU/Linux, si una máquina recién entregada o formateada no tiene ningún servicio"
echo -e "remoto activo, no es posible entrar por la red directamente. Para evitar sentarte"
echo -e "en cada una de las 20 a 30 computadoras a escribir comandos manualmente, este"
echo -e "asistente provee dos mecanismos de despliegue ultrarrápido:"
echo
echo -e "  ${GREEN}1)${RESET} 🌐 ${BOLD}Servidor HTTP Local en el Aula (One-Liner de Red)${RESET}"
echo -e "     ${CYAN}Inicia un servidor web en esta PC. En las demás solo pegas una sola línea:${RESET}"
echo -e "     ${BOLD}${YELLOW}curl -s http://${IP_DOCENTE}:8080/bootstrap.sh | sudo bash${RESET}"
echo -e "     ${CYAN}Instala SSH, inyecta tu clave y se auto-registra en tu consola en vivo.${RESET}"
echo
echo -e "  ${GREEN}2)${RESET} 💾 ${BOLD}Generador de Pendrive USB Plug & Play (1 Clic por PC)${RESET}"
echo -e "     ${CYAN}Crea un instalador en un pendrive con acceso directo (.desktop) de doble clic.${RESET}"
echo -e "     ${CYAN}Lo enchufas en cada PC, haces doble clic y en 5 segundos queda lista y anotada.${RESET}"
echo
echo -e "  ${GREEN}3)${RESET} 🔍 ${BOLD}Escanear estado de SSH en las computadoras del laboratorio (Puerto 22)${RESET}"
echo -e "     ${CYAN}Comprueba cuáles PCs ya tienen SSH activo y cuáles faltan habilitar.${RESET}"
echo
echo -e "  ${RED}0)${RESET} 🔙 Volver al menú de red"
echo -e "${BLUE}----------------------------------------------------------------------${RESET}"
echo -ne "${BOLD}${YELLOW}Seleccione una opción [0-3]: ${RESET}"
read -r opcion

case "$opcion" in
    1)
        CLAVE_PUB=$(asegurar_clave_docente)
        PUERTO=8080

        echo
        imprimir_info "Iniciando servidor de aprovisionamiento en puerto $PUERTO..."
        python3 "$BASE_DIR/lib/servidor_aprovisionamiento.py" "$PUERTO" "$IP_DOCENTE" "$CLAVE_PUB" "$DIR_DATOS"
        ;;

    2)
        CLAVE_PUB=$(asegurar_clave_docente)
        echo
        echo -e "${BOLD}Generación de instalador para Pendrive USB:${RESET}"
        echo -ne "Ingrese la ruta de su Pendrive USB o carpeta destino [Enter para /tmp/instalador_usb_ssh]: "
        read -r ruta_destino
        DESTINO="${ruta_destino:-/tmp/instalador_usb_ssh}"

        mkdir -p "$DESTINO"

        # 1. Script ejecutable
        cat > "$DESTINO/instalar_ssh_aula.sh" <<EOF
#!/bin/bash
# ==============================================================================
# INSTALADOR USB POITE - HABILITACIÓN DE SSH DE AULA
# ==============================================================================

if [[ \$EUID -ne 0 ]]; then
    echo "Elevando permisos de administrador..."
    exec sudo bash "\$0" "\$@"
fi

clear
echo "======================================================================"
echo "   🚀 HABILITANDO SSH PARA GESTIÓN DE AULA (POITE)"
echo "======================================================================"

PKG_CMD=""
if command -v apt-get >/dev/null 2>&1; then
    PKG_CMD="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_CMD="dnf"
elif command -v pacman >/dev/null 2>&1; then
    PKG_CMD="pacman"
elif command -v zypper >/dev/null 2>&1; then
    PKG_CMD="zypper"
fi

echo "• Instalando servicio OpenSSH (\$PKG_CMD)..."
case "\$PKG_CMD" in
    apt)
        DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null 2>&1 || true
        DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server >/dev/null 2>&1
        systemctl enable --now ssh >/dev/null 2>&1 || service ssh start >/dev/null 2>&1 || true
        ;;
    dnf)
        dnf install -y openssh-server >/dev/null 2>&1
        systemctl enable --now sshd >/dev/null 2>&1 || true
        ;;
    pacman)
        pacman -Sy --noconfirm openssh >/dev/null 2>&1
        systemctl enable --now sshd >/dev/null 2>&1 || true
        ;;
    zypper)
        zypper install -y openssh >/dev/null 2>&1
        systemctl enable --now sshd >/dev/null 2>&1 || true
        ;;
esac

CLAVE_PUB="$CLAVE_PUB"
inyectar_clave() {
    local dir_ssh="\$1/.ssh"
    local auth_file="\$dir_ssh/authorized_keys"
    mkdir -p "\$dir_ssh"
    chmod 700 "\$dir_ssh"
    if [[ -n "\$CLAVE_PUB" ]]; then
        if ! grep -Fxq "\$CLAVE_PUB" "\$auth_file" 2>/dev/null; then
            echo "\$CLAVE_PUB" >> "\$auth_file"
        fi
        chmod 600 "\$auth_file"
    fi
}

inyectar_clave "/root"
for home_dir in /home/*; do
    if [[ -d "\$home_dir" ]]; then
        user_name=\$(basename "\$home_dir")
        inyectar_clave "\$home_dir"
        chown -R "\$user_name:\$user_name" "\$home_dir/.ssh" 2>/dev/null || true
    fi
done

IP_LOCAL=\$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \\K[0-9.]+' || hostname -I | awk '{print \$1}')
HOST_LOCAL=\$(hostname)
DIR_SCRIPT="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"

# Guardar registro en el propio pendrive
echo "\$(date '+%Y-%m-%d %H:%M:%S') | \$IP_LOCAL | \$HOST_LOCAL" >> "\$DIR_SCRIPT/equipos_instalados.txt" 2>/dev/null || true

echo
echo "✅ ¡Servicio OpenSSH instalado y activado en puerto 22!"
echo "🔑 Clave del docente inyectada para acceso sin contraseña."
echo "📋 IP de este equipo anotada: \$IP_LOCAL (\$HOST_LOCAL)"
echo "======================================================================"
EOF
        chmod +x "$DESTINO/instalar_ssh_aula.sh"

        # 2. Acceso directo .desktop
        cat > "$DESTINO/Habilitar_SSH_Aula.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Habilitar SSH Aula (POITE)
Comment=Instala y activa SSH en esta PC
Exec=bash -c 'cd "\$(dirname "%k")" && sudo ./instalar_ssh_aula.sh; echo; read -p "Presione Enter para finalizar..."'
Icon=utilities-terminal
Terminal=true
Categories=System;
EOF
        chmod +x "$DESTINO/Habilitar_SSH_Aula.desktop"

        # 3. Archivo explicativo
        cat > "$DESTINO/LEEME.txt" <<EOF
INSTRUCCIONES DE USO:
1. Conecte este pendrive a la computadora del estudiante.
2. Ejecute el script 'instalar_ssh_aula.sh' o haga doble clic en 'Habilitar_SSH_Aula.desktop'.
3. En 5 segundos, la computadora tendrá SSH instalado y quedará anotada en 'equipos_instalados.txt'.
EOF

        echo
        imprimir_exito "Archivos de instalación USB generados en: $DESTINO"
        echo "   • instalar_ssh_aula.sh        (Script instalador autónomo)"
        echo "   • Habilitar_SSH_Aula.desktop  (Lanzador de 1-Clic para el escritorio)"
        echo "   • LEEME.txt                   (Instrucciones de uso)"
        echo
        imprimir_info "Copia estos archivos a tu pendrive. Al enchufarlo en cada máquina, solo ejecútalo y listo."
        pausar
        ;;

    3)
        echo
        imprimir_info "Escaneando estado del puerto 22 (SSH) en equipos del laboratorio..."

        # Obtener lista de IPs a verificar
        IPS_A_VERIFICAR=()
        if [[ -f "$ARCHIVO_IPS" ]] && [[ -s "$ARCHIVO_IPS" ]]; then
            mapfile -t IPS_A_VERIFICAR < "$ARCHIVO_IPS"
        else
            SUBRED=$(obtener_subred_local)
            RED_BASE=$(echo "$SUBRED" | cut -d'/' -f1 | cut -d'.' -f1-3)
            echo -e "${CYAN}No hay archivo de IPs previas; sondeando segmento $RED_BASE.1 a 254...${RESET}"
            # Ping sweep rápido
            for i in $(seq 1 254); do
                ping -c 1 -W 1 "$RED_BASE.$i" >/dev/null 2>&1 &
            done
            wait
            while read -r ip _ _ mac _ estado; do
                if [[ "$estado" =~ (REACHABLE|DELAY|STALE) && "$mac" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
                    IPS_A_VERIFICAR+=("$ip")
                fi
            done < <(ip neigh show dev "$(obtener_interfaz_activa)" 2>/dev/null)
        fi

        if [[ ${#IPS_A_VERIFICAR[@]} -eq 0 ]]; then
            imprimir_aviso "No se encontraron equipos respondiendo en la red."
            pausar
            exit 0
        fi

        echo
        printf "%-17s %-22s %-20s\n" "DIRECCIÓN IP" "HOSTNAME" "ESTADO SERVICIO SSH"
        echo "----------------------------------------------------------------------"

        ABIERTOS=0
        CERRADOS=0

        for ip in "${IPS_A_VERIFICAR[@]}"; do
            ip=$(echo "$ip" | tr -d '\r\n' | xargs)
            [[ -z "$ip" || "$ip" =~ ^# ]] && continue

            name=$(resolver_hostname_ip "$ip")

            # Test de puerto 22 con timeout
            if timeout 1.2 bash -c "echo > /dev/tcp/$ip/22" 2>/dev/null; then
                printf "%-17s %-22s %b\n" "$ip" "$name" "${GREEN}✅ ACTIVO (Puerto 22)${RESET}"
                ((ABIERTOS++))
            else
                printf "%-17s %-22s %b\n" "$ip" "$name" "${RED}❌ NO INSTALADO / CERRADO${RESET}"
                ((CERRADOS++))
            fi
        done

        echo "----------------------------------------------------------------------"
        echo -e "${BOLD}Resumen:${RESET} Equipos con SSH activo: ${GREEN}$ABIERTOS${RESET} | Equipos pendientes de activar: ${RED}$CERRADOS${RESET}"
        if [[ $CERRADOS -gt 0 ]]; then
            echo
            imprimir_aviso "Hay $CERRADOS equipos sin SSH. Puedes usar la opción 1 (Servidor HTTP) o 2 (Pendrive) para activarlos en segundos."
        fi
        pausar
        ;;

    0)
        ;;
    *)
        imprimir_error "Opción no válida."
        ;;
esac
