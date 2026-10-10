#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Sellado y Generalización del Sistema para Clonar con Clonezilla (Linux Sysprep)
# Ejecutar ÚNICAMENTE en la Máquina Virtual / Imagen Maestra antes de clonar.
# Autor: Prof. Gabriel Vázquez (Docente de Informática · INET / ANEP)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🧹 SELLAR Y GENERALIZAR SISTEMA PARA CLONEZILLA" "Sysprep Linux: Resetea machine-id, llaves SSH y cachés antes de apagar y clonar"

if ! asegurar_root; then
    exit 1
fi

echo -e "${RED}${BOLD}⚠️  ¡ATENCIÓN DOCENTE POITE!${RESET}"
echo -e "Este script prepara esta computadora o máquina virtual para ser ${BOLD}clonada en masa${RESET}."
echo
echo -e "${YELLOW}Acciones técnicas que se llevarán a cabo:${RESET}"
echo -e "  • 🆔 ${BOLD}Vaciar /etc/machine-id:${RESET} Evita que todas las PCs del aula reciban la MISMA IP por DHCP."
echo -e "  • 🔑 ${BOLD}Eliminar llaves de host SSH:${RESET} Cada PC clonada generará sus propias llaves únicas al arrancar."
echo -e "  • 🌐 ${BOLD}Limpiar reglas persistentes de red:${RESET} Evita que las tarjetas de red se renombren como eth1, eth2..."
echo -e "  • ⚙️  ${BOLD}Verificar servicio poite-firstboot:${RESET} Garantiza regeneración automática de identidad."
echo -e "  • 🧹 ${BOLD}Limpieza profunda:${RESET} Elimina cachés de paquetes, logs acumulados e historial de terminal."
echo
echo -e "${BOLD}${RED}¿Confirma que este equipo es la Imagen Maestra y desea proceder al sellado? (s/N): ${RESET}"
read -r confirmar_sellado

if [[ ! "$confirmar_sellado" =~ ^[sS]$ ]]; then
    imprimir_info "Operación de sellado cancelada. No se realizaron cambios."
    pausar
    exit 0
fi

echo
echo -e "${CYAN}Iniciando proceso de sellado y generalización...${RESET}"
echo "----------------------------------------------------------------------"

# 1. Asegurar poite-firstboot.sh y poite-firstboot.service
echo -e "1. Verificando servicio de primer arranque (poite-firstboot)..."
if [[ ! -f "/usr/local/bin/poite-firstboot.sh" ]]; then
    sudo tee "/usr/local/bin/poite-firstboot.sh" > /dev/null <<'EOF'
#!/bin/bash
LOG_FILE="/var/log/poite-firstboot.log"
echo "[$(date)] Primer arranque detectado tras clonación..." >> "$LOG_FILE"
if [[ ! -s /etc/machine-id ]]; then
    systemd-machine-id-setup >> "$LOG_FILE" 2>&1 || dbus-uuidgen --ensure=/etc/machine-id >> "$LOG_FILE" 2>&1
fi
if [[ -d /var/lib/dbus && ! -f /var/lib/dbus/machine-id ]]; then
    ln -sf /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true
fi
if [[ ! -f /etc/ssh/ssh_host_rsa_key && ! -f /etc/ssh/ssh_host_ed25519_key ]]; then
    ssh-keygen -A >> "$LOG_FILE" 2>&1
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true
fi
systemctl disable poite-firstboot.service 2>/dev/null || true
echo "[$(date)] Regeneración completada exitosamente." >> "$LOG_FILE"
EOF
    sudo chmod +x "/usr/local/bin/poite-firstboot.sh"
fi

if [[ ! -f "/etc/systemd/system/poite-firstboot.service" ]]; then
    sudo tee "/etc/systemd/system/poite-firstboot.service" > /dev/null <<'EOF'
[Unit]
Description=Asistente POITE - Regenerador de Identidad Post-Clonacion
Before=ssh.service sshd.service NetworkManager.service
ConditionPathExists=/usr/local/bin/poite-firstboot.sh

[Service]
Type=oneshot
ExecStart=/usr/local/bin/poite-firstboot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
fi

sudo systemctl daemon-reload
sudo systemctl enable poite-firstboot.service >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓ Servicio poite-firstboot habilitado para el próximo arranque.${RESET}"

# 2. Reseteo de machine-id (CRÍTICO para evitar colisión de IP en DHCP)
echo -e "2. Reseteando identificador de máquina (machine-id)..."
if [[ -f "/etc/machine-id" ]]; then
    sudo truncate -s 0 /etc/machine-id
fi
if [[ -f "/var/lib/dbus/machine-id" ]]; then
    sudo rm -f /var/lib/dbus/machine-id
    sudo ln -sf /etc/machine-id /var/lib/dbus/machine-id
fi
echo -e "  ${GREEN}✓ /etc/machine-id vaciado a 0 bytes (se regenerará al arrancar cada PC).${RESET}"

# 3. Eliminar llaves de host SSH
echo -e "3. Eliminando llaves de host SSH previas..."
sudo rm -f /etc/ssh/ssh_host_* 2>/dev/null || true
echo -e "  ${GREEN}✓ Llaves SSH eliminadas (cada PC generará su propio juego único).${RESET}"

# 4. Eliminar leases de DHCP y reglas udev
echo -e "4. Limpiando leases de DHCP y reglas persistentes de red..."
sudo rm -f /var/lib/NetworkManager/*lease* 2>/dev/null || true
sudo rm -f /var/lib/dhcp/* 2>/dev/null || true
sudo rm -f /var/lib/dhclient/* 2>/dev/null || true
sudo rm -f /etc/udev/rules.d/70-persistent-net.rules 2>/dev/null || true
echo -e "  ${GREEN}✓ Leases DHCP y asignaciones de red limpiadas.${RESET}"

# 5. Limpieza de paquetes y almacenamiento
echo -e "5. Liberando espacio y purgando cachés de software..."
limpiar_paquetes >/dev/null 2>&1 || true
sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null || true
echo -e "  ${GREEN}✓ Archivos temporales eliminados.${RESET}"

# 6. Truncar logs de sistema
echo -e "6. Truncando archivos de registro (logs)..."
if command -v journalctl >/dev/null 2>&1; then
    sudo journalctl --rotate >/dev/null 2>&1 || true
    sudo journalctl --vacuum-time=1s >/dev/null 2>&1 || true
fi
for logfile in /var/log/*.log /var/log/syslog /var/log/messages; do
    if [[ -f "$logfile" ]]; then
        sudo truncate -s 0 "$logfile" 2>/dev/null || true
    fi
done
echo -e "  ${GREEN}✓ Logs truncados y vaciados.${RESET}"

# 7. Limpiar historial de bash
echo -e "7. Vaciando historial de comandos (bash history)..."
history -c 2>/dev/null || true
sudo rm -f ~/.bash_history /root/.bash_history 2>/dev/null || true
for user_dir in /home/*; do
    if [[ -d "$user_dir" ]]; then
        sudo rm -f "$user_dir/.bash_history" 2>/dev/null || true
    fi
done
echo -e "  ${GREEN}✓ Historial de terminal purgado.${RESET}"

echo "----------------------------------------------------------------------"
imprimir_exito "¡SISTEMA GENERALIZADO Y SELLADO EXITOSAMENTE!"
echo
echo -e "${YELLOW}La máquina virtual está en estado puro y lista para ser clonada con Clonezilla.${RESET}"
echo -e "${RED}${BOLD}IMPORTANTE:${RESET} Si enciende la máquina normalmente ahora, regenerará su identidad."
echo -e "Debe ${BOLD}apagar la máquina ahora${RESET} y arrancar con Clonezilla (Live ISO o Servidor Multicast)."
echo
echo -ne "${BOLD}${CYAN}¿Desea APAGAR esta computadora / máquina virtual AHORA MISMO? (S/n): ${RESET}"
read -r resp_apagar

if [[ -z "$resp_apagar" || "$resp_apagar" =~ ^[sS]$ ]]; then
    echo
    echo -e "${RED}Apagando el sistema de forma segura... ¡Nos vemos tras la clonación!${RESET}"
    sleep 2
    sudo shutdown -h now
    exit 0
else
    imprimir_info "Apagado pospuesto. Recuerde apagar la máquina antes de capturar el disco."
fi

pausar
