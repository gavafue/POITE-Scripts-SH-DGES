#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Instalador y Configurador de Ansible para Automatización de Aulas GNU/Linux
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🤖 INSTALACIÓN Y CONFIGURACIÓN DE ANSIBLE" "Herramienta de automatización y gestión masiva para computadoras del aula"

if ! asegurar_root; then
    exit 1
fi

echo -e "${CYAN}1. Verificando estado actual de Ansible...${RESET}"
if command -v ansible >/dev/null 2>&1; then
    imprimir_info "Ansible ya se encuentra instalado en este equipo ($(ansible --version 2>/dev/null | head -n1))."
else
    echo -e "${CYAN}2. Instalando Ansible y herramientas auxiliares (sshpass) para '$DISTRO_FAMILY'...${RESET}"
    actualizar_repositorios

    case "$DISTRO_FAMILY" in
        debian)
            instalar_paquetes ansible sshpass python3-pip
            ;;
        redhat)
            instalar_paquetes ansible sshpass
            ;;
        arch)
            instalar_paquetes ansible sshpass
            ;;
        suse)
            instalar_paquetes ansible sshpass
            ;;
        *)
            instalar_paquetes ansible sshpass || true
            ;;
    esac
fi

if ! command -v ansible >/dev/null 2>&1; then
    imprimir_error "No se pudo completar la instalación de Ansible en este sistema."
    pausar
    exit 1
fi

imprimir_exito "Ansible instalado correctamente: $(ansible --version | head -n1)"
echo

echo -e "${CYAN}3. Creando entorno y plantillas de Ansible para el laboratorio...${RESET}"
DIR_ANSIBLE="$BASE_DIR/ansible"
DIR_PLAYBOOKS="$DIR_ANSIBLE/playbooks"
mkdir -p "$DIR_PLAYBOOKS" "$DIR_DATOS"

# 3.1 Archivo de configuración ansible.cfg
CONFIG_ANSIBLE="$DIR_ANSIBLE/ansible.cfg"
cat > "$CONFIG_ANSIBLE" <<'EOF'
[defaults]
inventory = ../RegistrarIP/inventario_ansible.ini
host_key_checking = False
timeout = 10
deprecation_warnings = False
stdout_callback = yaml
interpreter_python = auto_silent
retry_files_enabled = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF
imprimir_exito "Configuración creada en $CONFIG_ANSIBLE (host_key_checking desactivado para el aula)."

# 3.2 Inventario inicial por defecto si no existe
INVENTARIO_INI="$DIR_DATOS/inventario_ansible.ini"
if [[ ! -f "$INVENTARIO_INI" ]]; then
    cat > "$INVENTARIO_INI" <<'EOF'
# ==============================================================================
# INVENTARIO DE ANSIBLE - LABORATORIO DE INFORMÁTICA
# Generado automáticamente por Asistente POITE
# ==============================================================================

[laboratorio]
# Formato: <hostname> ansible_host=<ip> ansible_user=<usuario>
# Ejemplo:
# lab1-pc01 ansible_host=192.168.1.101 ansible_user=docente
# lab1-pc02 ansible_host=192.168.1.102 ansible_user=docente

[laboratorio:vars]
ansible_user=docente
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
    imprimir_exito "Inventario base creado en $INVENTARIO_INI."
fi

# 3.3 Playbooks educativos listos para usar
echo
echo -e "${CYAN}4. Generando playbooks esenciales de administración de aula...${RESET}"

# Playbook 1: Test de conectividad (Ping)
cat > "$DIR_PLAYBOOKS/01_ping_aula.yml" <<'EOF'
---
- name: Probar conectividad con todas las máquinas del aula
  hosts: laboratorio
  gather_facts: false
  tasks:
    - name: Ping a los equipos
      ansible.builtin.ping:
EOF

# Playbook 2: Sincronización horaria (Montevideo)
cat > "$DIR_PLAYBOOKS/02_sincronizar_reloj.yml" <<'EOF'
---
- name: Sincronizar zona horaria y reloj en todo el laboratorio
  hosts: laboratorio
  become: true
  tasks:
    - name: Configurar zona horaria a America/Montevideo
      ansible.builtin.timezone:
        name: America/Montevideo

    - name: Habilitar sincronización NTP con timedatectl
      ansible.builtin.command: timedatectl set-ntp true
      changed_when: false

    - name: Sincronizar reloj de hardware
      ansible.builtin.command: hwclock --systohc
      changed_when: false
EOF

# Playbook 3: Actualización de paquetes
cat > "$DIR_PLAYBOOKS/03_actualizar_paquetes.yml" <<'EOF'
---
- name: Actualizar paquetes en todas las PCs del laboratorio
  hosts: laboratorio
  become: true
  tasks:
    - name: Actualizar repositorios y paquetes (Debian/Ubuntu)
      ansible.builtin.apt:
        update_cache: yes
        upgrade: yes
      when: ansible_os_family == 'Debian'

    - name: Actualizar paquetes (RedHat/Fedora)
      ansible.builtin.dnf:
        name: "*"
        state: latest
      when: ansible_os_family == 'RedHat'
EOF

# Playbook 4: Crear usuario alumno
cat > "$DIR_PLAYBOOKS/04_crear_usuario_alumno.yml" <<'EOF'
---
- name: Crear usuario estándar de estudiante en el aula
  hosts: laboratorio
  become: true
  tasks:
    - name: Crear usuario alumno con shell bash
      ansible.builtin.user:
        name: alumno
        comment: "Estudiante de Informática"
        shell: /bin/bash
        state: present
EOF

# Playbook 5: Apagado masivo del laboratorio
cat > "$DIR_PLAYBOOKS/05_apagar_aula.yml" <<'EOF'
---
- name: Apagar todas las PCs del aula al finalizar el turno
  hosts: laboratorio
  become: true
  tasks:
    - name: Enviar orden de apagado inmediato
      ansible.builtin.command: shutdown -h now
      async: 1
      poll: 0
      ignore_errors: true
EOF

imprimir_exito "5 playbooks generados en $DIR_PLAYBOOKS/:"
echo "   • 01_ping_aula.yml              (Verificar estado de red de todas las PCs)"
echo "   • 02_sincronizar_reloj.yml      (Arreglar reloj y certificados SSL en lote)"
echo "   • 03_actualizar_paquetes.yml    (Actualizar software en todo el laboratorio)"
echo "   • 04_crear_usuario_alumno.yml   (Asegurar cuenta común de estudiante)"
echo "   • 05_apagar_aula.yml            (Apagado remoto al terminar el turno de clase)"

echo
echo -e "${BOLD}${GREEN}Ejemplo de ejecución masiva:${RESET}"
echo -e "   ${YELLOW}cd $DIR_ANSIBLE && ansible-playbook playbooks/01_ping_aula.yml${RESET}"

pausar
