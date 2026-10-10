#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Configuración del usuario para inicio de sesión automático (Autologin)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "🔁 CONFIGURAR LOGIN AUTOMÁTICO (AUTOLOGIN)" "Permite que la computadora inicie directamente en el escritorio del alumno/docente"

if ! asegurar_root; then
    exit 1
fi

echo -e "${BOLD}Usuarios locales disponibles:${RESET}"
cut -d: -f1,3 /etc/passwd | awk -F: '$2 >= 1000 && $2 < 60000 {print "  • " $1}'
echo

read -p "👤 Ingrese el nombre del usuario para inicio automático (o 'ninguno' para deshabilitar): " nuevo_usuario

if [[ "$nuevo_usuario" != "ninguno" ]] && ! id "$nuevo_usuario" &>/dev/null; then
    imprimir_error "El usuario '$nuevo_usuario' no existe en el sistema."
    pausar
    exit 1
fi

modificado=false

# 1. Soporte para LightDM (Xubuntu, Lubuntu, Ceibal, Mint)
if [[ -f "/etc/lightdm/lightdm.conf" ]] || [[ -d "/etc/lightdm/lightdm.conf.d" ]]; then
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    CONFIG_LIGHTDM="/etc/lightdm/lightdm.conf.d/50-poite-autologin.conf"
    if [[ "$nuevo_usuario" == "ninguno" ]]; then
        sudo rm -f "$CONFIG_LIGHTDM"
        imprimir_exito "Autologin deshabilitado en LightDM."
    else
        sudo tee "$CONFIG_LIGHTDM" > /dev/null <<EOF
[Seat:*]
autologin-user=$nuevo_usuario
autologin-user-timeout=0
EOF
        imprimir_exito "Configurado autologin para '$nuevo_usuario' en LightDM ($CONFIG_LIGHTDM)."
    fi
    modificado=true
fi

# 2. Soporte para GDM3 (Ubuntu Desktop con GNOME) y GDM (Fedora / RHEL / Arch)
for GDM_CONF in "/etc/gdm3/custom.conf" "/etc/gdm/custom.conf"; do
    if [[ -f "$GDM_CONF" ]]; then
        if [[ "$nuevo_usuario" == "ninguno" ]]; then
            sudo sed -i 's/^AutomaticLoginEnable=.*/AutomaticLoginEnable=false/' "$GDM_CONF"
            imprimir_exito "Autologin deshabilitado en GDM ($GDM_CONF)."
        else
            sudo sed -i 's/^#\?AutomaticLoginEnable=.*/AutomaticLoginEnable=true/' "$GDM_CONF"
            sudo sed -i "s/^#\?AutomaticLogin=.*/AutomaticLogin=$nuevo_usuario/" "$GDM_CONF"
            imprimir_exito "Configurado autologin para '$nuevo_usuario' en GDM ($GDM_CONF)."
        fi
        modificado=true
    fi
done

# 3. Soporte para SDDM (KDE Plasma en Fedora, Kubuntu, etc.)
if [[ -d "/etc/sddm.conf.d" ]] || [[ -f "/etc/sddm.conf" ]]; then
    sudo mkdir -p /etc/sddm.conf.d
    SDDM_AUTO="/etc/sddm.conf.d/autologin.conf"
    if [[ "$nuevo_usuario" == "ninguno" ]]; then
        sudo rm -f "$SDDM_AUTO"
        imprimir_exito "Autologin deshabilitado en SDDM."
    else
        sudo tee "$SDDM_AUTO" > /dev/null <<EOF
[Autologin]
User=$nuevo_usuario
Session=default
EOF
        imprimir_exito "Configurado autologin para '$nuevo_usuario' en SDDM ($SDDM_AUTO)."
    fi
    modificado=true
fi

if [[ "$modificado" = false ]]; then
    imprimir_aviso "No se detectó un Display Manager estándar (LightDM, GDM o SDDM)."
else
    imprimir_info "Los cambios surtirán efecto en el próximo reinicio del equipo."
fi

pausar