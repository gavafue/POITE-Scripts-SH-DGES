#!/bin/bash

echo "Activando y configurando el servicio SSH..."

sudo apt update
sudo apt install -y openssh-server

sudo systemctl enable ssh
sudo systemctl start ssh

estado=$(sudo systemctl is-active ssh)

if [[ "$estado" == "active" ]]; then
  ip=$(hostname -I | awk '{print $1}')
  echo "✅ SSH activado. Puede conectarse con:"
  echo "    ssh usuario@$ip"
else
  echo "❌ Hubo un error al iniciar el servicio SSH."
fi

read -p "Presione enter para continuar..."
echo "Volviendo al menú principal..."
# Fin del script
# Este script activa y configura el servicio SSH en un sistema Linux.
# Primero, actualiza la lista de paquetes e instala el servidor SSH.
# Luego, habilita el servicio SSH para que se inicie automáticamente al arrancar el sistema y lo inicia inmediatamente.
# Después, verifica el estado del servicio SSH y muestra la dirección IP del sistema para que el usuario pueda conectarse a través de SSH.
# Si el servicio se activa correctamente, se muestra un mensaje de éxito con la dirección IP.
# Si hay un error al iniciar el servicio, se muestra un mensaje de error.
# Al final, se espera que el usuario presione enter para continuar y luego se vuelve al menú principal.
# Se recomienda ejecutar este script con permisos de superusuario (root) para garantizar que todas las funciones del asistente funcionen correctamente.