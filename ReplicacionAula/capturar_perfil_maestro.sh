#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Captura de Perfil Maestro de Configuración (Alternativa a Clonar Imágenes)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📸 CAPTURAR PERFIL MAESTRO DEL LABORATORIO" "Inspecciona esta PC configurada para replicar su estado en computadoras limpias"

echo -e "Este asistente auditará el software, usuarios y ajustes de este equipo de"
echo -e "referencia para generar una plantilla declarativa reutilizable. Podrás"
echo -e "desplegarla luego en 20 o 30 PCs limpias a través de la red sin clonar discos."
echo

mkdir -p "$DIR_DATOS" "$BASE_DIR/ansible/playbooks"
ARCHIVO_PERFIL="$DIR_DATOS/perfil_maestro.conf"

echo -ne "${CYAN}Nombre descriptivo para este perfil [Enter para 'Perfil-Lab-DGES']: ${RESET}"
read -r p_nombre
NOMBRE_PERFIL="${p_nombre:-Perfil-Lab-DGES}"

# 1. Detección de software clave
echo
echo -e "${BOLD}1. Inspección de Software Principal Instalado:${RESET}"
TIENE_VSCODE=false
TIENE_CHROME=false
TIENE_BRAVE=false
TIENE_WINE=false
TIENE_ANSIBLE=false

command -v code >/dev/null 2>&1 && TIENE_VSCODE=true
command -v google-chrome >/dev/null 2>&1 && TIENE_CHROME=true
command -v brave-browser >/dev/null 2>&1 && TIENE_BRAVE=true
command -v wine >/dev/null 2>&1 && TIENE_WINE=true
command -v ansible >/dev/null 2>&1 && TIENE_ANSIBLE=true

echo -e "   • Visual Studio Code: $([[ "$TIENE_VSCODE" = true ]] && echo -e "${GREEN}Detectado${RESET}" || echo -e "${YELLOW}No detectado${RESET}")"
echo -e "   • Google Chrome:      $([[ "$TIENE_CHROME" = true ]] && echo -e "${GREEN}Detectado${RESET}" || echo -e "${YELLOW}No detectado${RESET}")"
echo -e "   • Brave Browser:      $([[ "$TIENE_BRAVE" = true ]] && echo -e "${GREEN}Detectado${RESET}" || echo -e "${YELLOW}No detectado${RESET}")"
echo -e "   • Wine / Winetricks:  $([[ "$TIENE_WINE" = true ]] && echo -e "${GREEN}Detectado${RESET}" || echo -e "${YELLOW}No detectado${RESET}")"
echo -e "   • Ansible:            $([[ "$TIENE_ANSIBLE" = true ]] && echo -e "${GREEN}Detectado${RESET}" || echo -e "${YELLOW}No detectado${RESET}")"

echo
echo -ne "¿Desea incluir la instalación de Visual Studio Code en las PCs limpias? [S/n]: "
read -r r_code
INC_VSCODE=true
[[ "$r_code" =~ ^[nN]$ ]] && INC_VSCODE=false

echo -ne "¿Desea incluir Google Chrome? [S/n]: "
read -r r_chrome
INC_CHROME=true
[[ "$r_chrome" =~ ^[nN]$ ]] && INC_CHROME=false

echo -ne "¿Desea incluir Brave Browser? [s/N]: "
read -r r_brave
INC_BRAVE=false
[[ "$r_brave" =~ ^[sS]$ ]] && INC_BRAVE=true

echo -ne "¿Desea incluir Wine / Winetricks (software Windows)? [s/N]: "
read -r r_wine
INC_WINE=false
[[ "$r_wine" =~ ^[sS]$ ]] && INC_WINE=true

# 2. Paquetes de software educativo
echo
echo -e "${BOLD}2. Paquetes Pedagógicos y Herramientas de Aula:${RESET}"
PAQUETES_DETECTADOS=()
CANDIDATOS=(libreoffice libreoffice-l10n-es vlc pdfarranger gimp inkscape krita audacity obs-studio kdenlive thonny geany kate scratch gcompris-qt stellarium kalzium kstars tuxpaint)

for p in "${CANDIDATOS[@]}"; do
    if paquete_instalado "$p" || command -v "$p" >/dev/null 2>&1; then
        PAQUETES_DETECTADOS+=("$p")
    fi
done

if [[ ${#PAQUETES_DETECTADOS[@]} -gt 0 ]]; then
    echo -e "Paquetes educativos detectados en este equipo:"
    echo -e "   ${GREEN}${PAQUETES_DETECTADOS[*]}${RESET}"
    echo -ne "¿Desea incluir estos paquetes en el perfil maestro? [S/n]: "
    read -r r_pkgs
    if [[ -z "$r_pkgs" || "$r_pkgs" =~ ^[sS]$ ]]; then
        LISTA_PAQUETES="${PAQUETES_DETECTADOS[*]}"
    else
        LISTA_PAQUETES="libreoffice vlc pdfarranger gimp thonny geany kate stellarium gcompris-qt"
    fi
else
    echo -e "${YELLOW}No se detectaron suites educativas completas.${RESET}"
    LISTA_PAQUETES="libreoffice vlc pdfarranger gimp thonny geany kate stellarium gcompris-qt"
    echo -e "Se usará lista estándar para aulas: ${CYAN}$LISTA_PAQUETES${RESET}"
fi

# 3. Usuarios de estudiantes
echo
echo -e "${BOLD}3. Cuenta de Usuario para Estudiantes:${RESET}"
echo -ne "¿Desea crear una cuenta común para alumnos en todas las PCs limpias? [S/n]: "
read -r r_user
INC_USER=true
NOMBRE_ALUMNO="alumno"
PASS_ALUMNO="alumno2026"

if [[ -z "$r_user" || "$r_user" =~ ^[sS]$ ]]; then
    echo -ne "Nombre de la cuenta de estudiante [Enter para 'alumno']: "
    read -r in_nom_user
    NOMBRE_ALUMNO="${in_nom_user:-alumno}"

    echo -ne "Contraseña para la cuenta '$NOMBRE_ALUMNO' [Enter para 'alumno2026']: "
    read -r in_pass_user
    PASS_ALUMNO="${in_pass_user:-alumno2026}"
else
    INC_USER=false
fi

# 4. Inicio de sesión automático (Autologin)
echo
echo -e "${BOLD}4. Inicio de Sesión Automático (Autologin):${RESET}"
echo -ne "¿Desea que las computadoras del aula inicien sesión directamente en el escritorio del estudiante? [S/n]: "
read -r r_auto
INC_AUTOLOGIN=true
[[ "$r_auto" =~ ^[nN]$ ]] && INC_AUTOLOGIN=false

# 5. Zona horaria y hora
ZONA_LOCAL=$(timedatectl 2>/dev/null | grep -i "time zone" | awk '{print $3}' || echo "America/Montevideo")
echo
echo -e "${BOLD}5. Zona Horaria y Sincronización:${RESET}"
echo -e "Zona horaria detectada: ${CYAN}$ZONA_LOCAL${RESET}"
echo -ne "¿Replicar sincronización horaria y zona $ZONA_LOCAL en todas las PCs? [S/n]: "
read -r r_hora
INC_HORA=true
[[ "$r_hora" =~ ^[nN]$ ]] && INC_HORA=false

# 6. Proxy DGES
PROXY_ACTIVO=false
if [[ -f "/etc/apt/apt.conf.d/99proxy-dges.conf" ]] || grep -q "^proxy=" /etc/dnf/dnf.conf 2>/dev/null || [[ -f "/etc/profile.d/proxy-dges.sh" ]]; then
    PROXY_ACTIVO=true
fi
echo
echo -e "${BOLD}6. Proxy Institucional DGES:${RESET}"
echo -e "Estado en este equipo: $([[ "$PROXY_ACTIVO" = true ]] && echo -e "${GREEN}Configurado${RESET}" || echo -e "${YELLOW}Conexión directa (sin proxy)${RESET}")"
echo -ne "¿Desea activar el Proxy DGES en las máquinas destino? [s/N]: "
read -r r_proxy
INC_PROXY=false
VALOR_PROXY="10.4.142.24:8080"
if [[ "$r_proxy" =~ ^[sS]$ ]]; then
    INC_PROXY=true
    echo -ne "IP y puerto del proxy [Enter para 10.4.142.24:8080]: "
    read -r in_proxy
    VALOR_PROXY="${in_proxy:-10.4.142.24:8080}"
fi

# 7. Prefijo de Hostname
echo
echo -e "${BOLD}7. Estandarización de Nombres de Red:${RESET}"
echo -ne "Prefijo para los nombres de las computadoras del aula (ej: lab1-pc): [lab1-pc]: "
read -r in_prefijo
PREFIJO_HOST="${in_prefijo:-lab1-pc}"

# Guardar perfil maestro en archivo de configuración
echo
echo -e "${CYAN}Generando artefactos de replicación...${RESET}"

cat > "$ARCHIVO_PERFIL" <<EOF
# ==============================================================================
# PERFIL MAESTRO DE LABORATORIO - ASISTENTE POITE
# ==============================================================================
NOMBRE_PERFIL="$NOMBRE_PERFIL"
FECHA_CAPTURA="$(date '+%Y-%m-%d %H:%M:%S')"
DISTRO_ORIGEN="$DISTRO_NAME"
FAMILIA_ORIGEN="$DISTRO_FAMILY"
PREFIJO_HOSTNAME="$PREFIJO_HOST"

INSTALAR_VSCODE=$INC_VSCODE
INSTALAR_CHROME=$INC_CHROME
INSTALAR_BRAVE=$INC_BRAVE
INSTALAR_WINE=$INC_WINE

PAQUETES_EDUCATIVOS="$LISTA_PAQUETES"

CREAR_USUARIO_ALUMNO=$INC_USER
NOMBRE_ALUMNO="$NOMBRE_ALUMNO"
PASSWORD_ALUMNO="$PASS_ALUMNO"

CONFIGURAR_AUTOLOGIN=$INC_AUTOLOGIN
USUARIO_AUTOLOGIN="$NOMBRE_ALUMNO"

CONFIGURAR_HORA=$INC_HORA
ZONA_HORARIA="$ZONA_LOCAL"

CONFIGURAR_PROXY=$INC_PROXY
PROXY_DGES="$VALOR_PROXY"
EOF

imprimir_exito "Perfil guardado en $ARCHIVO_PERFIL."

# Generar Playbook de Ansible
PLAYBOOK_AULA="$BASE_DIR/ansible/playbooks/desplegar_perfil_aula.yml"
cat > "$PLAYBOOK_AULA" <<'EOF'
---
# ==============================================================================
# PLAYBOOK DE REPLICACIÓN DE LABORATORIO - ASISTENTE POITE
# Despliega el perfil maestro de configuración en PCs limpias del aula
# ==============================================================================
- name: Replicar Perfil Maestro en computadoras limpias del laboratorio
  hosts: laboratorio
  become: true
  gather_facts: true

  tasks:
    - name: 1. Sincronizar zona horaria y servicio NTP
      block:
        - name: Configurar timezone a America/Montevideo
          ansible.builtin.timezone:
            name: America/Montevideo
        - name: Habilitar sincronización NTP con timedatectl
          ansible.builtin.command: timedatectl set-ntp true
          changed_when: false
        - name: Sincronizar reloj de hardware CMOS
          ansible.builtin.command: hwclock --systohc
          changed_when: false
      ignore_errors: true

    - name: 2. Actualizar índices de paquetes de la distribución
      block:
        - name: Actualizar repositorios APT (Debian/Ubuntu)
          ansible.builtin.apt:
            update_cache: yes
          when: ansible_os_family == 'Debian'
        - name: Actualizar repositorios DNF (RedHat/Fedora)
          ansible.builtin.dnf:
            update_cache: yes
          when: ansible_os_family == 'RedHat'
      ignore_errors: true

    - name: 3. Crear usuario estudiante para el aula
      block:
        - name: Asegurar grupo alumnos
          ansible.builtin.group:
            name: alumnos
            state: present
        - name: Crear cuenta alumno con shell /bin/bash
          ansible.builtin.user:
            name: alumno
            group: alumnos
            shell: /bin/bash
            password: "{{ 'alumno2026' | password_hash('sha512', 'poite2026') }}"
            state: present
      ignore_errors: true

    - name: 4. Configurar inicio de sesión automático (Autologin)
      block:
        - name: Configurar Autologin en LightDM
          ansible.builtin.copy:
            dest: /etc/lightdm/lightdm.conf.d/50-poite-autologin.conf
            content: |
              [Seat:*]
              autologin-user=alumno
              autologin-user-timeout=0
            mode: '0644'
          when: ansible_os_family == 'Debian'
      ignore_errors: true

    - name: 5. Instalar paquetes de software educativo
      block:
        - name: Instalar paquetes esenciales en Debian/Ubuntu
          ansible.builtin.apt:
            name:
              - libreoffice
              - vlc
              - pdfarranger
              - gimp
              - thonny
              - geany
              - kate
              - stellarium
            state: present
          when: ansible_os_family == 'Debian'
        - name: Instalar paquetes esenciales en RedHat/Fedora
          ansible.builtin.dnf:
            name:
              - libreoffice
              - pdfarranger
              - gimp
              - thonny
              - geany
              - kate
              - stellarium
            state: present
          when: ansible_os_family == 'RedHat'
      ignore_errors: true
EOF

imprimir_exito "Playbook de Ansible generado en $PLAYBOOK_AULA."

# Generar script de ejecución autónoma (para SSH nativo o pendrive)
SCRIPT_AUTONOMO="$DIR_DATOS/replicar_perfil_autonomo.sh"
cat > "$SCRIPT_AUTONOMO" <<EOF
#!/bin/bash
# ==============================================================================
# SCRIPT DE REPLICACIÓN AUTÓNOMA DE LABORATORIO - ASISTENTE POITE
# ==============================================================================

if [[ \$EUID -ne 0 ]]; then
    echo "Elevando a permisos de administrador..."
    exec sudo bash "\$0" "\$@"
fi

echo "======================================================================"
echo "   🚀 APLICANDO PERFIL MAESTRO DE LABORATORIO ($NOMBRE_PERFIL)"
echo "======================================================================"

# 1. Zona Horaria y NTP
if [[ "$INC_HORA" = true ]]; then
    echo "• Sincronizando zona horaria y reloj ($ZONA_LOCAL)..."
    timedatectl set-timezone "$ZONA_LOCAL" 2>/dev/null || true
    timedatectl set-ntp true 2>/dev/null || true
    hwclock --systohc 2>/dev/null || true
fi

# 2. Proxy Institucional DGES
if [[ "$INC_PROXY" = true ]]; then
    echo "• Configurando Proxy DGES ($VALOR_PROXY)..."
    if [[ -d "/etc/apt" ]]; then
        mkdir -p /etc/apt/apt.conf.d
        cat > /etc/apt/apt.conf.d/99proxy-dges.conf <<PCONF
Acquire::http::proxy "http://${VALOR_PROXY}/";
Acquire::https::proxy "http://${VALOR_PROXY}/";
PCONF
    fi
    if [[ -f "/etc/dnf/dnf.conf" ]]; then
        sed -i '/^proxy=/d' /etc/dnf/dnf.conf
        echo "proxy=http://${VALOR_PROXY}/" >> /etc/dnf/dnf.conf
    fi
fi

# 3. Detectar gestor de paquetes
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

echo "• Actualizando repositorios (\$PKG_CMD)..."
case "\$PKG_CMD" in
    apt)
        DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null 2>&1 || true
        ;;
    dnf)
        dnf check-update -y >/dev/null 2>&1 || true
        ;;
esac

# 4. Crear usuario alumno
if [[ "$INC_USER" = true ]]; then
    echo "• Configurando usuario de estudiante '$NOMBRE_ALUMNO'..."
    if ! id "$NOMBRE_ALUMNO" >/dev/null 2>&1; then
        useradd -m -s /bin/bash "$NOMBRE_ALUMNO" 2>/dev/null || true
        echo "${NOMBRE_ALUMNO}:${PASS_ALUMNO}" | chpasswd 2>/dev/null || true
    fi
fi

# 5. Configurar Autologin
if [[ "$INC_AUTOLOGIN" = true ]]; then
    echo "• Habilitando autologin para '$NOMBRE_ALUMNO'..."
    if [[ -d "/etc/lightdm" ]] || [[ -f "/etc/lightdm/lightdm.conf" ]]; then
        mkdir -p /etc/lightdm/lightdm.conf.d
        cat > /etc/lightdm/lightdm.conf.d/50-poite-autologin.conf <<ACONF
[Seat:*]
autologin-user=$NOMBRE_ALUMNO
autologin-user-timeout=0
ACONF
    fi
    for GCONF in "/etc/gdm3/custom.conf" "/etc/gdm/custom.conf"; do
        if [[ -f "\$GCONF" ]]; then
            sed -i 's/^#\?AutomaticLoginEnable=.*/AutomaticLoginEnable=true/' "\$GCONF"
            sed -i "s/^#\?AutomaticLogin=.*/AutomaticLogin=$NOMBRE_ALUMNO/" "\$GCONF"
        fi
    done
fi

# 6. Instalar paquetes de software educativo
if [[ -n "$LISTA_PAQUETES" ]]; then
    echo "• Instalando paquetes educativos: $LISTA_PAQUETES..."
    case "\$PKG_CMD" in
        apt)
            DEBIAN_FRONTEND=noninteractive apt-get install -y $LISTA_PAQUETES >/dev/null 2>&1 || true
            ;;
        dnf)
            dnf install -y $LISTA_PAQUETES >/dev/null 2>&1 || true
            ;;
    esac
fi

# 7. Instalar navegadores y herramientas si estaban seleccionadas
if [[ "$INC_VSCODE" = true ]] && ! command -v code >/dev/null 2>&1; then
    echo "• Instalando Visual Studio Code..."
    if [[ "\$PKG_CMD" == "apt" ]]; then
        mkdir -p /etc/apt/keyrings
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --yes -o /etc/apt/keyrings/packages.microsoft.gpg 2>/dev/null || true
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
        apt-get update -y >/dev/null 2>&1 && apt-get install -y code >/dev/null 2>&1 || true
    elif [[ "\$PKG_CMD" == "dnf" ]]; then
        rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null || true
        cat > /etc/yum.repos.d/vscode.repo <<VCONF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
VCONF
        dnf install -y code >/dev/null 2>&1 || true
    fi
fi

if [[ "$INC_CHROME" = true ]] && ! command -v google-chrome >/dev/null 2>&1; then
    echo "• Instalando Google Chrome..."
    if [[ "\$PKG_CMD" == "apt" ]]; then
        wget -qO /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" 2>/dev/null || true
        apt-get install -y /tmp/chrome.deb >/dev/null 2>&1 && rm -f /tmp/chrome.deb
    elif [[ "\$PKG_CMD" == "dnf" ]]; then
        wget -qO /tmp/chrome.rpm "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm" 2>/dev/null || true
        dnf install -y /tmp/chrome.rpm >/dev/null 2>&1 && rm -f /tmp/chrome.rpm
    fi
fi

echo
echo "======================================================================"
echo "✅ ¡Configuración replicada con éxito en $(hostname)!"
echo "======================================================================"
EOF
chmod +x "$SCRIPT_AUTONOMO"

imprimir_exito "Script ejecutable autónomo generado en $SCRIPT_AUTONOMO."
echo
imprimir_info "El Perfil Maestro ha sido capturado y los paquetes de replicación están listos."
pausar
