#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Visualizador de Perfil Maestro de Configuración
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

ARCHIVO_PERFIL="$DIR_DATOS/perfil_maestro.conf"

imprimir_encabezado "📋 PERFIL MAESTRO DE CONFIGURACIÓN DEL AULA" "Detalle del estado del sistema a replicar en computadoras limpias"

if [[ ! -f "$ARCHIVO_PERFIL" ]]; then
    imprimir_aviso "Aún no se ha capturado un Perfil Maestro en este equipo."
    echo -e "Se recomienda ejecutar primero la opción de captura desde la PC de referencia."
    pausar
    exit 0
fi

# Cargar perfil
# shellcheck disable=SC1090
source "$ARCHIVO_PERFIL"

echo -e "${BOLD}Metadatos del Perfil:${RESET}"
echo -e "   • Nombre del Perfil: ${BOLD}${CYAN}${NOMBRE_PERFIL}${RESET}"
echo -e "   • Fecha de captura:  ${YELLOW}${FECHA_CAPTURA}${RESET}"
echo -e "   • Sistema de origen: ${GREEN}${DISTRO_ORIGEN}${RESET} (${FAMILIA_ORIGEN})"
echo -e "   • Prefijo hostnames: ${MAGENTA}${PREFIJO_HOSTNAME:-lab1-pc}${RESET}"
echo

echo -e "${BOLD}Software Principal a Replicar:${RESET}"
echo -e "   • Visual Studio Code: $([[ "$INSTALAR_VSCODE" = true ]] && echo -e "${GREEN}Sí${RESET}" || echo -e "${YELLOW}No${RESET}")"
echo -e "   • Google Chrome:      $([[ "$INSTALAR_CHROME" = true ]] && echo -e "${GREEN}Sí${RESET}" || echo -e "${YELLOW}No${RESET}")"
echo -e "   • Brave Browser:      $([[ "$INSTALAR_BRAVE" = true ]] && echo -e "${GREEN}Sí${RESET}" || echo -e "${YELLOW}No${RESET}")"
echo -e "   • WineHQ / Windows:   $([[ "$INSTALAR_WINE" = true ]] && echo -e "${GREEN}Sí${RESET}" || echo -e "${YELLOW}No${RESET}")"
echo

echo -e "${BOLD}Paquetes Educativos Incluidos:${RESET}"
echo -e "   ${CYAN}${PAQUETES_EDUCATIVOS}${RESET}"
echo

echo -e "${BOLD}Ajustes de Usuarios y Acceso:${RESET}"
echo -e "   • Crear usuario alumno: $([[ "$CREAR_USUARIO_ALUMNO" = true ]] && echo -e "${GREEN}Sí ($NOMBRE_ALUMNO)${RESET}" || echo -e "${YELLOW}No${RESET}")"
echo -e "   • Autologin de aula:    $([[ "$CONFIGURAR_AUTOLOGIN" = true ]] && echo -e "${GREEN}Activado para $USUARIO_AUTOLOGIN${RESET}" || echo -e "${YELLOW}Desactivado${RESET}")"
echo

echo -e "${BOLD}Red y Sincronización:${RESET}"
echo -e "   • Zona horaria y NTP: $([[ "$CONFIGURAR_HORA" = true ]] && echo -e "${GREEN}$ZONA_HORARIA${RESET}" || echo -e "${YELLOW}Omitido${RESET}")"
echo -e "   • Proxy DGES:         $([[ "$CONFIGURAR_PROXY" = true ]] && echo -e "${GREEN}$PROXY_DGES${RESET}" || echo -e "${YELLOW}Conexión directa${RESET}")"
echo

echo -e "${BOLD}Artefactos Generados:${RESET}"
echo -e "   • Configuración:  ${CYAN}$ARCHIVO_PERFIL${RESET}"
echo -e "   • Playbook:       ${CYAN}$BASE_DIR/ansible/playbooks/desplegar_perfil_aula.yml${RESET}"
echo -e "   • Script remoto:  ${CYAN}$DIR_DATOS/replicar_perfil_autonomo.sh${RESET}"

pausar
