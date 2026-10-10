# 🖥️ Asistente POITE · DGES Uruguay

Suite interactiva en **Bash** para la administración ágil, diagnóstico de redes, mantenimiento de sistemas y automatización en laboratorios educativos **GNU/Linux** de la **Dirección General de Educación Secundaria (DGES - ANEP)**.

Desarrollado y mantenido por el **Prof. Gabriel Vázquez** (Docente de Informática egresado de INET / CFE).

[![Licencia](https://img.shields.io/badge/Licencia-GPL--3.0-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Bash](https://img.shields.io/badge/Shell-Bash%205+-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Plataforma-Ubuntu%20%7C%20Debian%20%7C%20Ceibal-FCC624?logo=linux&logoColor=black)](https://www.kernel.org)
[![Contacto](https://img.shields.io/badge/Ceibal-Docente-00833E?logo=gmail&logoColor=white)](mailto:gabriel.vazquez@docente.ceibal.edu.uy)

---

## 🎯 Propósito del Proyecto

En el trabajo diario de los **laboratorios de informática liceales** y aulas tecnológicas, los docentes y Profesores Orientadores en Informática y Tecnología Educativa (**POITE**) enfrentan tareas repetitivas en múltiples equipos:

* Computadoras que pierden la hora por **baterías CMOS de la BIOS agotadas**, impidiendo la navegación HTTPS por errores de certificados SSL.
* Equipos que requieren configuración de **Proxy institucional de DGES** para actualizar paquetes o acceder a repositorios oficiales.
* Creación manual o por lotes de **cuentas de estudiantes** con permisos controlados (evitando privilegios innecesarios de `sudo`).
* **Distribución remota masiva** de configuraciones o scripts a través de la red local (LAN) por SSH utilizando listas de IPs o direcciones MAC.
* Instalación de programas pedagógicos esenciales y suites ofimáticas sin lidiar con comandos complejos en terminal.

Este asistente transforma todas estas operaciones en un menú visual, rápido, guiado e intuitivo.

---

## 🚀 Instalación y Acceso Global (`poite`)

Puedes ejecutar el asistente directamente o instalar el comando global para abrirlo en cualquier momento desde la terminal con una sola palabra:

### Opción 1: Instalación del Comando Global (Recomendada)
```bash
git clone https://github.com/gavafue/POITE-Scripts-SH-DGES.git
cd POITE-Scripts-SH-DGES
sudo ./instalar_comando.sh
```
Una vez instalado, simplemente escribe en cualquier consola:
```bash
poite
```

### Opción 2: Ejecución Directa
```bash
cd POITE-Scripts-SH-DGES
chmod +x menu.sh
./menu.sh
```

---

## 🧭 Estructura y Módulos de la Suite

```text
POITE-Scripts-SH-DGES/
├── menu.sh                         # 🖥️ Menú principal interactivo con métricas en vivo
├── instalar_comando.sh             # 🚀 Enlace global /usr/local/bin/poite
├── lib/
│   └── comun.sh                    # 🧰 Librería central: detección de distro, IPs, sudo y estilos
├── Red/
│   ├── diagnostico_red.sh          # ⚡ Test exprés de conectividad, Gateway, DNS y Ceibal
│   ├── proxy_DGES.sh               # 🛡️ Gestor de Proxy DGES (activar, cambiar IP, desactivar)
│   ├── reiniciar_red.sh            # 🔄 Reinicio seguro de NetworkManager y networking
│   ├── chequear_repositorios.sh    # 📦 Verificación dinámica de repositorios oficiales APT
│   ├── registrar_ip.sh             # 📝 Registro de IP del host en ips.txt
│   ├── conexion_remota_ip.sh       # 📤 Distribución y ejecución remota por SSH (IP)
│   ├── limpiar_archivo_ip.sh       # 🧹 Vaciado seguro del registro de IPs
│   ├── registrar_mac.sh            # 🏷️ Detección y registro de dirección física MAC
│   ├── conexion_remota_mac.sh      # 📤 Descubrimiento ARP y ejecución remota por MAC
│   └── limpiar_archivo_mac.sh      # 🧹 Vaciado seguro del registro de MACs
├── Usuarios/
│   ├── crear_usuario.sh            # ➕ Creación individual con opción de rol alumno o sudo
│   ├── crear_usuarios_lote.sh      # 📂 Importación masiva por CSV con shell /bin/bash y CRLF fix
│   ├── cambiar_usuario.sh          # 🔁 Autologin con soporte dual para LightDM y GDM3
│   ├── resetear_password.sh        # 🔑 Restablecimiento asistido de contraseñas
│   └── eliminar_usuario.sh         # ➖ Eliminación segura con protección de cuentas críticas
├── Sistema/
│   ├── cpu.sh                      # 🧠 Información detallada de CPU (lscpu, modelo, núcleos)
│   ├── memoria.sh                  # 🪫 Memoria RAM y Swap con porcentaje de ocupación
│   ├── discos.sh                   # 💽 Almacenamiento, puntos de montaje y particiones
│   ├── so.sh                       # 🏷️ Sistema operativo, versión y tiempo encendido (uptime)
│   ├── kernel.sh                   # 🧩 Versión del kernel Linux y arquitectura
│   ├── procesos.sh                 # 🧮 Visor interactivo de procesos activos
│   ├── hardware.sh                 # 🖧 Reporte completo de hardware con lshw
│   ├── variables.sh                # 📦 Variables de entorno de la sesión
│   └── completo.sh                 # 📋 Auditoría integral consolidada del equipo
├── Mantenimiento/
│   ├── arreglar_reloj_ubuntu.sh    # 🕒 Sincronización NTP y zona horaria (solución pila BIOS agotada)
│   ├── reparar_dependencias.sh     # 🧱 Reparación segura de dpkg y paquetes APT bloqueados
│   ├── limpieza_disco.sh           # 🧹 Liberación de espacio (cachés, thumbnails, journalctl)
│   └── ssh.sh                      # 🔐 Instalación y arranque del servicio OpenSSH
├── InstalacionesFrecuentes/
│   ├── instalar_visual_studio_code.sh # 🧑‍💻 Instalador oficial de VS Code (keyrings modernos)
│   ├── instalar_chrome.sh          # 🌐 Google Chrome oficial con validación de arquitectura
│   ├── instalar_brave.sh           # 🦁 Brave Browser con repositorio APT corregido
│   ├── instalar_wine.sh            # 🍷 WineHQ con arquitectura i386 y fallback automático
│   └── suite_educativa.sh          # 📚 Suite clasificada por áreas (ofimática, programación, ciencias, arte)
└── RegistrarIP/                    # 📁 Directorio central de persistencia
    ├── ips.txt                     # Listado de IPs registradas
    ├── macs.txt                    # Listado de MACs registradas
    ├── remoto.sh                   # Script a distribuir remotamente por el aula
    └── registro_ejecuciones.log    # Historial de ejecuciones SSH
```

---

## 🛠️ Aspectos Técnicos Destacados de Ingeniería

1. **Resolución Canónica de Rutas:**
   Todos los scripts resuelven la ruta absoluta mediante `BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"`, permitiendo invocarlos desde cualquier directorio de trabajo o a través de enlaces simbólicos sin fallos de ruta relativa.

2. **Detección Automática de Distribución:**
   El módulo central identifica el nombre, versión y codename de la distribución (`focal`, `jammy`, `noble`, `bookworm`), adaptando los repositorios APT y evitando conflictos entre diferentes versiones de Ubuntu/Debian.

3. **Autologin Híbrido:**
   Compatible tanto con entornos ligeros basados en **LightDM** (Xubuntu, Lubuntu, Ceibal Linux) como con entornos de escritorio basados en **GDM3** (Ubuntu estándar con GNOME).

4. **Tratamiento Seguro de Datos:**
   La creación de usuarios por lotes normaliza los saltos de línea Windows (`CRLF / \r\n`) provenientes de archivos exportados desde Excel o LibreOffice Calc, y asigna explícitamente `/bin/bash` para asegurar un entorno de terminal completo para los estudiantes.

---

## 👤 Autor

**Prof. Gabriel Vázquez**  
*Docente de Informática — Uruguay*  
* Instituto Normal de Enseñanza Técnica (INET - CFE / ANEP)
* DGETP - UTU · Instituto Superior Brazo Oriental (ISBO)
* DGES - Secundaria · POITE en Educación Media
* 📧 Correo: [gabriel.vazquez@docente.ceibal.edu.uy](mailto:gabriel.vazquez@docente.ceibal.edu.uy)
* 💼 LinkedIn: [linkedin.com/in/gavafue](https://www.linkedin.com/in/gavafue)

---

## 📄 Licencia

Este proyecto se distribuye bajo la Licencia **GPL-3.0**. Libre para uso, estudio, modificación y redistribución en toda la comunidad educativa pública.
