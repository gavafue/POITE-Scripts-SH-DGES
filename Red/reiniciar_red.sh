#!/bin/bash

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${YELLOW}🔄 Reiniciando servicios de red...${RESET}"

# Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}⚠️ Este script requiere privilegios de superusuario. Use 'sudo'.${RESET}"
  exit 1
fi

# Intentar reiniciar NetworkManager (usado en Ubuntu Desktop)
if systemctl restart NetworkManager 2>/dev/null; then
  echo -e "${GREEN}✅ NetworkManager reiniciado correctamente.${RESET}"
else
  echo -e "${YELLOW}ℹ️ NetworkManager no está instalado o no se pudo reiniciar.${RESET}"
fi

# Intentar reiniciar networking (más común en servidores)
if systemctl restart networking 2>/dev/null; then
  echo -e "${GREEN}✅ Servicio 'networking' reiniciado correctamente.${RESET}"
else
  echo -e "${YELLOW}ℹ️ El servicio 'networking' no está disponible o no se pudo reiniciar.${RESET}"
fi

# Mostrar estado de las interfaces de red
echo -e "${YELLOW}📡 Estado de las interfaces de red:${RESET}"
ip a

read -p "Presione Enter para volver al menú..."
