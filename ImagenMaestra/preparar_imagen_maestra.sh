#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Preparación Automatizada de la Imagen Maestra (VirtualBox / PC Personal)
# Configura: Conexión Directa, Usuario Alumno, Autologin, SSH, Clave Docente,
# Suite Educativa, VS Code, Chrome, Reloj NTP y Generador de Identidad Firstboot
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📦 ACONDICIONAMIENTO DE IMAGEN MAESTRA (VIRTUALBOX)" "Preparación en PC personal con conexión directa (El Proxy DGES se desplegará tras clonar en el liceo)"

if ! asegurar_root; then
    exit 1
fi

imprimir_resumen_distro
echo
echo -e "${CYAN}ℹ️  METODOLOGÍA DE TRABAJO DEL POITE (Prof. Gabriel Vázquez):${RESET}"
echo -e "  • ${BOLD}Esta fase se realiza en su PC personal / conexión directa a Internet.${RESET}"
echo -e "  • ${GREEN}NO necesita configurar Proxy DGES aquí.${RESET} Las descargas de paquetes serán directas y rápidas."
echo -e "  • La clonación con Clonezilla en el aula tampoco requiere proxy (tráfico local LAN)."
echo -e "  • ${YELLOW}El Proxy DGES y los Hostnames (lab1-pcXX) se desplegarán en lote con Ansible el Día 1 en el liceo.${RESET}"
echo
echo -e "${BOLD}Tareas a realizar en esta máquina virtual de referencia:${RESET}"
echo -e "  1. 🌐 Verificación de conexión directa a Internet (o proxy opcional si ya está en liceo)"
echo -e "  2. 🔄 Actualización de repositorios y paquetes base"
echo -e "  3. 👤 Creación y configuración de la cuenta de estudiante ('alumno')"
echo -e "  4. 🔁 Configuración de inicio de sesión automático (Autologin de escritorio)"
echo -e "  5. 🔐 Instalación de OpenSSH Server e inyección de Clave SSH del Docente"
echo -e "  6. 📚 Instalación de Suite Educativa + Google Chrome + VS Code"
echo -e "  7. 🕒 Sincronización de Reloj (America/Montevideo) y NTP"
echo -e "  8. ⚙️  Instalación del regenerador de identidad para primer arranque físico"
echo
echo -ne "${BOLD}¿Desea iniciar la preparación integral de la Imagen Maestra? (S/n): ${RESET}"
read -r resp_iniciar
if [[ -n "$resp_iniciar" && ! "$resp_iniciar" =~ ^[sS]$ ]]; then
    imprimir_info "Operación cancelada."
    exit 0
fi

# ------------------------------------------------------------------------------
# PASO 1: CONECTIVIDAD E INTERNET
# ------------------------------------------------------------------------------
echo
imprimir_encabezado "🌐 PASO 1/8: CONECTIVIDAD A INTERNET" "Verificando acceso para descargas de software"

echo -e "¿Está preparando esta imagen en su PC personal con Internet directo o dentro del liceo con Proxy?"
echo -e "  ${GREEN}1)${RESET} Conexión DIRECTA a Internet (Recomendado: PC Personal / Hogar / Red sin proxy)"
echo -e "  ${YELLOW}2)${RESET} Red con PROXY Institucional DGES (Solo si está armando la VM dentro del liceo)"
echo -ne "${BOLD}Seleccione [1-2] [Enter para 1]: ${RESET}"
read -r opt_red_tipo

if [[ "$opt_red_tipo" == "2" ]]; then
    bash "$BASE_DIR/Red/proxy_DGES.sh" <<< "1"
else
    imprimir_exito "Modo Conexión Directa seleccionado. Omitiendo configuración de proxy."
fi

# ------------------------------------------------------------------------------
# PASO 2: ACTUALIZACIÓN DE REPOSITORIOS
# ------------------------------------------------------------------------------
echo
imprimir_encabezado "🔄 PASO 2/8: ACTUALIZACIÓN DE REPOSITORIOS" "Refrescando lista de software disponible"
actualizar_repositorios || imprimir_aviso "Continuando con paquetes en caché..."

# ------------------------------------------------------------------------------
# PASO 3: CUENTA DE ESTUDIANTE 'ALUMNO'
# ------------------------------------------------------------------------------
echo
imprimir_encabezado "👤 PASO 3/8: CUENTA DE ESTUDIANTE" "Configuración del usuario local para los estudiantes"

echo -ne "Nombre de usuario para los estudiantes [Enter para 'alumno']: "
read -r user_in
USUARIO_ALUMNO="${user_in:-alumno}"

echo -ne "Contraseña para el usuario '$USUARIO_ALUMNO' [Enter para 'alumno']: "
read -r pass_in
PASS_ALUMNO="${pass_in:-alumno}"

if ! id "$USUARIO_ALUMNO" &>/dev/null; then
    echo -e "${CYAN}Creando usuario '$USUARIO_ALUMNO'...${RESET}"
    if [[ "$DISTRO_FAMILY" == "debian" ]] && command -v adduser >/dev/null 2>&1; then
        sudo adduser --disabled-password --gecos "Estudiante de Informática" "$USUARIO_ALUMNO"
    else
        sudo useradd -m -s /bin/bash -c "Estudiante de Informática" "$USUARIO_ALUMNO"
    fi
    echo "$USUARIO_ALUMNO:$PASS_ALUMNO" | sudo chpasswd
    imprimir_exito "Usuario '$USUARIO_ALUMNO' creado con éxito."
else
    echo "$USUARIO_ALUMNO:$PASS_ALUMNO" | sudo chpasswd
    imprimir_info "El usuario '$USUARIO_ALUMNO' ya existía. Contraseña actualizada."
fi

# Añadir a grupos multimedia de hardware
for grp in audio video plugdev netdev dialout input cdrom floppy; do
    if getent group "$grp" >/dev/null 2>&1; then
        sudo usermod -aG "$grp" "$USUARIO_ALUMNO" 2>/dev/null || true
    fi
done

echo -ne "¿Desea otorgar permisos de administrador (sudo) al usuario '$USUARIO_ALUMNO'? (s/N): "
read -r resp_sudo_alumno
if [[ "$resp_sudo_alumno" =~ ^[sS]$ ]]; then
    sudo usermod -aG "$GRUPO_ADMIN" "$USUARIO_ALUMNO"
    imprimir_exito "Usuario '$USUARIO_ALUMNO' con privilegios de sudo."
else
    sudo gpasswd -d "$USUARIO_ALUMNO" "$GRUPO_ADMIN" 2>/dev/null || true
    imprimir_info "Usuario '$USUARIO_ALUMNO' configurado como estándar de estudiante."
fi

# ------------------------------------------------------------------------------
# PASO 4: AUTOLOGIN (INICIO AUTOMÁTICO)
# ------------------------------------------------------------------------------
echo
imprimir_encabezado "🔁 PASO 4/8: INICIO AUTOMÁTICO (AUTOLOGIN)" "Para que las PCs arranquen directamente en el escritorio del alumno"

echo -ne "¿Habilitar Autologin para '$USUARIO_ALUMNO'? (S/n): "
read -r resp_auto
if [[ -z "$resp_auto" || "$resp_auto" =~ ^[sS]$ ]]; then
    auto_configurado=false

    # LightDM
    if [[ -f "/etc/lightdm/lightdm.conf" ]] || [[ -d "/etc/lightdm/lightdm.conf.d" ]]; then
        sudo mkdir -p /etc/lightdm/lightdm.conf.d
        sudo tee "/etc/lightdm/lightdm.conf.d/50-poite-autologin.conf" > /dev/null <<EOF
[Seat:*]
autologin-user=$USUARIO_ALUMNO
autologin-user-timeout=0
EOF
        auto_configurado=true
        imprimir_exito "Autologin configurado en LightDM."
    fi

    # GDM3 / GDM
    for gdm_f in "/etc/gdm3/custom.conf" "/etc/gdm/custom.conf"; do
        if [[ -f "$gdm_f" ]]; then
            sudo sed -i 's/^#\?AutomaticLoginEnable=.*/AutomaticLoginEnable=true/' "$gdm_f"
            sudo sed -i "s/^#\?AutomaticLogin=.*/AutomaticLogin=$USUARIO_ALUMNO/" "$gdm_f"
            auto_configurado=true
            imprimir_exito "Autologin configurado en GDM ($gdm_f)."
        fi
    done

    # SDDM
    if [[ -d "/etc/sddm.conf.d" ]] || [[ -f "/etc/sddm.conf" ]]; then
        sudo mkdir -p /etc/sddm.conf.d
        sudo tee "/etc/sddm.conf.d/autologin.conf" > /dev/null <<EOF
[Autologin]
User=$USUARIO_ALUMNO
Session=default
EOF
        auto_configurado=true
        imprimir_exito "Autologin configurado en SDDM."
    fi

    if [[ "$auto_configurado" = false ]]; then
        imprimir_aviso "No se encontró LightDM, GDM o SDDM en este paso."
    fi
fi

# ------------------------------------------------------------------------------
# PASO 5: OPENSSH SERVER Y CLAVE PÚBLICA DOCENTE
# ------------------------------------------------------------------------------
echo
imprimir_encabezado "🔐 PASO 5/8: OPENSSH SERVER Y CLAVE DOCENTE" "Habilita la puerta para que Ansible controle todas las PCs el Día 1"

PAQUETE_SSH="openssh-server"
[[ "$DISTRO_FAMILY" == "arch" || "$DISTRO_FAMILY" == "suse" ]] && PAQUETE_SSH="openssh"
instalar_paquetes "$PAQUETE_SSH"

SERVICIO_SSH=$(servicio_nombre "ssh")
sudo systemctl enable "$SERVICIO_SSH" 2>/dev/null || true
sudo systemctl restart "$SERVICIO_SSH" 2>/dev/null || true
imprimir_exito "Servidor SSH habilitado en el arranque ($SERVICIO_SSH)."

echo
echo -e "${YELLOW}Inyección de Clave Pública SSH del Docente:${RESET}"
echo -e "Permite que la PC del docente se conecte a todas las máquinas clonadas sin pedir contraseñas."
echo -e "  [1] Pegar clave pública SSH manualmente (ej: ssh-ed25519 o ssh-rsa...)"
echo -e "  [2] Usar clave pública existente en este equipo (~/.ssh/*.pub)"
echo -e "  [3] Omitir inyección de clave pública por ahora"
echo -ne "${BOLD}Seleccione una opción [1-3]: ${RESET}"
read -r opt_ssh_key

CLAVE_DOCENTE_CONTENIDO=""
case "$opt_ssh_key" in
    1)
        echo -ne "${CYAN}Pegue su clave pública SSH completa y presione Enter:${RESET} "
        read -r CLAVE_DOCENTE_CONTENIDO
        ;;
    2)
        CLAVE_FILE=""
        for k in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub"; do
            if [[ -f "$k" ]]; then
                CLAVE_FILE="$k"
                break
            fi
        done
        if [[ -n "$CLAVE_FILE" ]]; then
            CLAVE_DOCENTE_CONTENIDO=$(cat "$CLAVE_FILE")
            echo -e "Clave cargada desde: $CLAVE_FILE"
        else
            imprimir_aviso "No se encontró ningún archivo .pub en $HOME/.ssh/."
        fi
        ;;
    *)
        imprimir_info "Inyección de clave pública omitida."
        ;;
esac

if [[ -n "$CLAVE_DOCENTE_CONTENIDO" ]]; then
    for target_home in "/home/$USUARIO_ALUMNO" "/root"; do
        if [[ -d "$target_home" ]]; then
            sudo mkdir -p "$target_home/.ssh"
            echo "$CLAVE_DOCENTE_CONTENIDO" | sudo tee -a "$target_home/.ssh/authorized_keys" >/dev/null
            sudo sort -u "$target_home/.ssh/authorized_keys" -o "$target_home/.ssh/authorized_keys"
            sudo chmod 700 "$target_home/.ssh"
            sudo chmod 600 "$target_home/.ssh/authorized_keys"
            if [[ "$target_home" == "/home/$USUARIO_ALUMNO" ]]; then
                sudo chown -R "$USUARIO_ALUMNO:$USUARIO_ALUMNO" "$target_home/.ssh"
            fi
        fi
    done
    imprimir_exito "Clave SSH docente inyectada en /home/$USUARIO_ALUMNO y /root."
fi

# ------------------------------------------------------------------------------
# PASO 6: SUITE EDUCATIVA Y APLICACIONES DE AULA
# ------------------------------------------------------------------------------
echo
imprimir_encabezado "📚 PASO 6/8: SOFTWARE PEDAGÓGICO Y DESARROLLO" "Instalación de paquetes de aula en la Imagen Maestra"

echo -e "Seleccione el conjunto de software para instalar en la imagen:"
echo -e "  ${GREEN}1)${RESET} 🌟 ${BOLD}Completo${RESET}: Suite Educativa + Google Chrome + Visual Studio Code"
echo -e "  ${GREEN}2)${RESET} 📝 Suite Educativa estándar (LibreOffice, GIMP, Geany, Thonny, Scratch)"
echo -e "  ${GREEN}3)${RESET} ⏭️  Omitir instalación de software (ya instalado manualmente)"
echo -ne "${BOLD}Seleccione una opción [1-3]: ${RESET}"
read -r opt_soft

case "$opt_soft" in
    1)
        bash "$BASE_DIR/InstalacionesFrecuentes/suite_educativa.sh" <<< "1" || true
        bash "$BASE_DIR/InstalacionesFrecuentes/instalar_chrome.sh" || true
        bash "$BASE_DIR/InstalacionesFrecuentes/instalar_visual_studio_code.sh" || true
        ;;
    2)
        bash "$BASE_DIR/InstalacionesFrecuentes/suite_educativa.sh" <<< "1" || true
        ;;
    *)
        imprimir_info "Paso de instalación de software omitido."
        ;;
esac

# ------------------------------------------------------------------------------
# PASO 7: RELOJ Y ZONA HORARIA
# ------------------------------------------------------------------------------
echo
imprimir_encabezado "🕒 PASO 7/8: RELOJ Y ZONA HORARIA" "Configura America/Montevideo y sincronización por red"
sudo timedatectl set-timezone America/Montevideo 2>/dev/null || true
sudo timedatectl set-ntp true 2>/dev/null || true
sudo hwclock --systohc 2>/dev/null || true
imprimir_exito "Zona horaria ajustada a America/Montevideo (Uruguay GMT-3) y NTP habilitado."

# ------------------------------------------------------------------------------
# PASO 8: SERVICIO FIRSTBOOT PARA REGENERACIÓN DE IDENTIDAD EN CLONES
# ------------------------------------------------------------------------------
echo
imprimir_encabezado "⚙️ PASO 8/8: GENERADOR DE IDENTIDAD EN PRIMER ARRANQUE" "Instala el servicio para regenerar machine-id y SSH keys tras clonar"

sudo tee "/usr/local/bin/poite-firstboot.sh" > /dev/null <<'EOF'
#!/bin/bash
# ==============================================================================
# SCRIPT DE PRIMER ARRANQUE TRAS CLONACIÓN CON CLONEZILLA - POITE DGES
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# Regenera machine-id (evita colisiones DHCP) y nuevas claves de host SSH
# ==============================================================================

LOG_FILE="/var/log/poite-firstboot.log"
echo "[$(date)] Iniciando regeneración de identidad en primer arranque..." >> "$LOG_FILE"

# 1. Regenerar machine-id si está vacío
if [[ ! -s /etc/machine-id ]]; then
    if command -v systemd-machine-id-setup >/dev/null 2>&1; then
        systemd-machine-id-setup >> "$LOG_FILE" 2>&1
    elif command -v dbus-uuidgen >/dev/null 2>&1; then
        dbus-uuidgen --ensure=/etc/machine-id >> "$LOG_FILE" 2>&1
    fi
    echo "[$(date)] Nuevo machine-id generado: $(cat /etc/machine-id 2>/dev/null)" >> "$LOG_FILE"
fi

if [[ -d /var/lib/dbus && ! -f /var/lib/dbus/machine-id ]]; then
    ln -sf /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true
fi

# 2. Regenerar SSH Host Keys si fueron eliminadas durante la generalización
if [[ ! -f /etc/ssh/ssh_host_rsa_key && ! -f /etc/ssh/ssh_host_ed25519_key ]]; then
    echo "[$(date)] Regenerando claves de host SSH..." >> "$LOG_FILE"
    ssh-keygen -A >> "$LOG_FILE" 2>&1
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true
fi

# 3. Auto-deshabilitar este servicio para que no vuelva a ejecutarse
systemctl disable poite-firstboot.service 2>/dev/null || true
echo "[$(date)] Identidad inicial completada con éxito. Servicio desactivado." >> "$LOG_FILE"
EOF

sudo chmod +x "/usr/local/bin/poite-firstboot.sh"

sudo tee "/etc/systemd/system/poite-firstboot.service" > /dev/null <<'EOF'
[Unit]
Description=Asistente POITE - Regenerador de Identidad Post-Clonacion (Prof. Gabriel Vazquez)
Before=ssh.service sshd.service NetworkManager.service
ConditionPathExists=/usr/local/bin/poite-firstboot.sh

[Service]
Type=oneshot
ExecStart=/usr/local/bin/poite-firstboot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable poite-firstboot.service >/dev/null 2>&1 || true
imprimir_exito "Servicio 'poite-firstboot.service' configurado y habilitado."

echo
imprimir_encabezado "🎉 ¡ACONDICIONAMIENTO DE LA IMAGEN MAESTRA FINALIZADO!" "Prof. Gabriel Vázquez · Docente de Informática (INET / ANEP)"
echo -e "${GREEN}La máquina virtual está completamente preparada y lista para el sellado.${RESET}"
echo
echo -e "${BOLD}${YELLOW}SIGUIENTE PASO ANTES DE CLONAR CON CLONEZILLA:${RESET}"
echo -e "Ejecute la opción ${BOLD}${CYAN}'Sellar y Generalizar Sistema para Clonar'${RESET} en el menú."
echo -e "Dicho proceso limpiará el machine-id actual, cachés y dejará la VM lista para apagarse."

pausar
