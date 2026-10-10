#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Guía y Metodología de Clonación Multicast en Red con Clonezilla
# Orientado a Laboratorios de Informática de Secundaria (DGES / UTU)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/comun.sh"

imprimir_encabezado "📖 GUÍA PRÁCTICA: CLONACIÓN MASIVA CON CLONEZILLA" "Flujo de trabajo para desplegar 25-30 PCs en red en 20 minutos"

cat <<'EOF'
----------------------------------------------------------------------
🎯 OBJETIVO:
Distribuir la Imagen Maestra configurada en VirtualBox a todas las
computadoras físicas del laboratorio de forma simultánea (Multicast).
----------------------------------------------------------------------

📦 FASE 1: CAPTURAR LA IMAGEN DESDE VIRTUALBOX
  1. En VirtualBox, asegúrese de haber ejecutado previamente el script:
     "Sellar y Generalizar Sistema para Clonar" y apague la VM.
  2. Inserte la ISO de Clonezilla Live en la lectora virtual de la VM.
  3. Encienda la VM y arranque desde la ISO de Clonezilla.
  4. Seleccione:
     • Idioma: es_ES (Español)
     • Teclado: Mantener por defecto
     • Modo: Start Clonezilla
     • Modo dispositivo: 'device-image' (disco a imagen)
     • Directorio destino: Pendrive USB 3.0 externo o carpeta compartida / SSH.
     • Operación: 'savedisk' (guardar disco completo sda).
     • Compresión: zstd (-z9p es ultra-rápido en CPUs multinúcleo).
  5. Clonezilla creará una carpeta con la imagen del sistema (ej: 2026-poite-img).

----------------------------------------------------------------------
🚀 FASE 2: DESPLIEGUE MULTICAST EN EL AULA (LITE SERVER)
  1. Conecte el pendrive USB con la imagen a una PC del aula (o PC docente).
  2. Arranque esa PC con Clonezilla Live.
  3. En el menú principal seleccione: 'Clonezilla lite-server'.
  4. Elija el modo de despliegue:
     • 'massive-deployment' -> 'from-device-image'
     • Seleccione el pendrive USB donde guardó la imagen en la Fase 1.
     • Seleccione 'multicast' (difusión simultánea a múltiples equipos).
  5. Configuración de clientes:
     • Elija 'clients-to-wait' (ej: indique 25 si tiene 25 máquinas) O
     • Elija 'time-to-wait' (ej: esperar 180 segundos antes de comenzar).
  6. El servidor Clonezilla quedará esperando a que los clientes se conecten.

----------------------------------------------------------------------
💻 FASE 3: ARRANQUE DE LAS COMPUTADORAS CLIENTES
  1. Encienda las demás computadoras del aula y arránquelas por:
     • Red (PXE Boot): Presione F12 / F11 al encender y elija 'Network/LAN' (si su switch y red lo permiten) O
     • Pendrives rápidos con Clonezilla Live configurados como clientes multicast.
  2. Las computadoras se conectarán al servidor lite-server y esperarán.
  3. Cuando se alcance el número de clientes o expire el temporizador,
     el servidor transmitirá los datos por multicast:
     ¡Todas las PCs se clonan AL MISMO TIEMPO sin sobrecargar la red!
     (Tiempo estimado: 15 a 25 minutos para todo el laboratorio).

----------------------------------------------------------------------
🎉 FASE 4: DÍA 1 TRAS LA CLONACIÓN (CONTROL CON POITE)
  1. Al reiniciar, todas las PCs físicas arrancarán con:
     ✓ Nuevo machine-id único y su propia IP asignada por DHCP.
     ✓ Nuevas claves de host SSH generadas automáticamente.
     ✓ Usuario 'alumno' con autologin listo para la clase.
     ✓ Proxy DGES activo en todo el sistema.
     ✓ Servidor SSH corriendo con la clave docente pre-instalada.
  2. Desde la computadora docente ejecute el Asistente POITE:
     Seleccione la opción:
     '🚀 PASO 3: POST-CLONACIÓN DÍA 1 (HOSTNAMES LAB1-PCXX Y ANSIBLE)'
     para asignar nombres secuenciales y tomar el control del laboratorio.
----------------------------------------------------------------------
EOF

pausar
