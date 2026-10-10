# 🖥️ Asistente POITE · DGES Uruguay

Suite interactiva en **Bash** para la administración ágil, diagnóstico de redes, mantenimiento de sistemas, mapeo de equipos, replicación de puestos y automatización en laboratorios educativos **GNU/Linux** de la **Dirección General de Educación Secundaria (DGES - ANEP)** y la comunidad educativa pública uruguaya.

Desarrollado y mantenido por el **Prof. Gabriel Vázquez** (Docente de Informática egresado de INET / CFE).

[![Licencia](https://img.shields.io/badge/Licencia-GPL--3.0-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Bash](https://img.shields.io/badge/Shell-Bash%205+-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Ansible](https://img.shields.io/badge/Automatización-Ansible%20Ready-EE0000?logo=ansible&logoColor=white)](https://www.ansible.com)
[![Linux](https://img.shields.io/badge/Plataforma-Ubuntu%20%7C%20Debian%20%7C%20Fedora%20%7C%20Arch%20%7C%20Ceibal-FCC624?logo=linux&logoColor=black)](https://www.kernel.org)
[![Contacto](https://img.shields.io/badge/Ceibal-Docente-00833E?logo=gmail&logoColor=white)](mailto:gabriel.vazquez@docente.ceibal.edu.uy)

---

## 🎯 Propósito del Proyecto

En el trabajo diario de los **laboratorios de informática liceales** y aulas tecnológicas, los docentes y Profesores Orientadores en Informática y Tecnología Educativa (**POITE**) enfrentan tareas repetitivas en múltiples equipos:

* **Replicación de laboratorios sin clonar discos:** Configurar una PC de referencia a mano y replicar automáticamente todo su software, usuarios y ajustes a 20 o 30 PCs limpias por red, evitando imágenes pesadas de Clonezilla (40 GB) y conflictos de hardware/drivers.
* **Aprovisionamiento express de SSH:** Habilitar acceso remoto en computadoras recién instaladas o clonadas sin necesidad de sentarse a escribir comandos manuales en cada una.
* **Mapeo del aula y detección de equipos:** Identificar rápidamente todas las computadoras activas en la subred escolar según su convención de nombre (ej: `lab1-pc01`, `lab1-pc02`, `lab2-pc15`) y alertar qué PCs están apagadas o desconectadas.
* **Asignación y estandarización de Hostnames:** Nombrar computadoras de forma individual o en lote secuencial para que cada máquina refleje su puesto físico en el aula.
* **Automatización masiva con Ansible:** Ejecutar tareas simultáneas (probar conectividad, sincronizar reloj, actualizar paquetes, crear cuentas de estudiantes o apagar todas las máquinas al finalizar el turno) en segundos.
* **Mantenimiento y contingencia:** Solucionar desincronizaciones de reloj por pilas BIOS agotadas, configurar Proxy DGES institucional y reparar gestores de paquetes bloqueados.

Este asistente transforma todas estas operaciones en un menú visual, rápido, guiado e intuitivo, **con detección automática de la distribución Linux instalada**.

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
├── menu.sh                         # 🖥️ Menú principal interactivo con métricas en vivo y detección de distro
├── instalar_comando.sh             # 🚀 Enlace y lanzador global /usr/local/bin/poite
├── lib/
│   ├── comun.sh                    # 🧰 Librería central: motor multi-distro, capas de abstracción y utilidades de red
│   └── servidor_aprovisionamiento.py # 🌐 Servidor HTTP para despliegue de SSH e indexado en vivo
├── ReplicacionAula/                # 🚀 Módulo de Replicación de Laboratorio (Alternativa a Clonar Discos)
│   ├── menu_replicacion.sh         # Submenú interactivo de replicación
│   ├── capturar_perfil_maestro.sh  # Captura software, usuarios y ajustes de la PC de referencia
│   ├── ver_perfil_maestro.sh       # Visualizador estructurado del perfil maestro
│   └── desplegar_perfil_remoto.sh  # Despliegue en red vía Ansible o SSH a PCs limpias
├── Red/
│   ├── diagnostico_red.sh          # ⚡ Test exprés de conectividad, Gateway, DNS y Ceibal
│   ├── mapear_red_equipos.sh       # 🗺️ Escaneo de subred, resolución de hostnames (lab1-pcXX) y alerta de ausentes
│   ├── asignar_hostname.sh         # 🏷️ Asignación de hostname local, remoto o en lote secuencial
│   ├── despliegue_ssh_aula.sh      # 🚀 Despliegue automatizado de SSH (Servidor HTTP / Pendrive USB)
│   ├── ejecutar_ansible_aula.sh    # 🤖 Lanzador guiado de playbooks de Ansible para el laboratorio
│   ├── proxy_DGES.sh               # 🛡️ Gestor de Proxy DGES multi-distro (APT, DNF y entorno global)
│   ├── reiniciar_red.sh            # 🔄 Reinicio seguro de NetworkManager y networking
│   ├── conexion_remota.sh          # 📤 Distribución y ejecución remota por SSH (por IP o MAC)
│   └── gestor_registros_red.sh     # 📋 Administrador de listas de IPs y MACs del laboratorio
├── Usuarios/
│   ├── crear_usuario.sh            # ➕ Creación individual con asignación de grupo (sudo / wheel)
│   ├── crear_usuarios_lote.sh      # 📂 Importación masiva por CSV con shell /bin/bash y CRLF fix
│   ├── cambiar_usuario.sh          # 🔁 Autologin multi-display manager (LightDM, GDM3, GDM, SDDM)
│   ├── resetear_password.sh        # 🔑 Restablecimiento asistido de contraseñas
│   └── eliminar_usuario.sh         # ➖ Eliminación segura con protección de cuentas críticas
├── Sistema/
│   ├── completo.sh                 # 📋 Auditoría integral consolidada del puesto
│   ├── so.sh                       # 🏷️ Sistema operativo, familia, versión, entorno gráfico y sesión
│   ├── cpu.sh                      # 🧠 Información detallada de CPU (lscpu, modelo, núcleos)
│   ├── memoria.sh                  # 🪫 Memoria RAM y Swap con porcentaje de ocupación
│   ├── discos.sh                   # 💽 Almacenamiento, puntos de montaje y particiones
│   ├── hardware.sh                 # 🖧 Reporte completo de hardware con lshw
│   ├── procesos.sh                 # 🧮 Visor interactivo de procesos activos
│   ├── kernel.sh                   # 🧩 Versión del kernel Linux y arquitectura
│   └── variables.sh                # 📦 Variables de entorno de la sesión
├── Mantenimiento/
│   ├── arreglar_reloj_ubuntu.sh    # 🕒 Sincronización NTP (Chrony / timesyncd) y reloj CMOS de BIOS
│   ├── reparar_dependencias.sh     # 🧱 Reparación adaptativa según gestor (APT, DNF, Pacman, Zypper)
│   ├── chequear_repositorios.sh    # 📦 Verificación dinámica de repositorios oficiales
│   ├── limpieza_disco.sh           # 🧹 Liberación de espacio (cachés de paquetes, thumbnails, logs)
│   └── ssh.sh                      # 🔐 Instalación, arranque y enlace al despliegue masivo de SSH
├── InstalacionesFrecuentes/
│   ├── instalar_ansible.sh         # 🤖 Instalador de Ansible, sshpass y generación de playbooks escolares
│   ├── instalar_visual_studio_code.sh # 🧑‍💻 VS Code oficial multi-distro (repositorios APT/DNF/Zypper/Arch)
│   ├── instalar_chrome.sh          # 🌐 Google Chrome oficial (.deb / .rpm) con validación de arquitectura
│   ├── instalar_brave.sh           # 🦁 Brave Browser oficial adaptado a la distribución
│   ├── instalar_wine.sh            # 🍷 WineHQ y Winetricks adaptado a Debian, Fedora, Arch y SUSE
│   └── suite_educativa.sh          # 📚 Suite clasificada por áreas con mapeo de paquetes multi-distro
├── ansible/                        # 📁 Entorno de Ansible para el aula
│   ├── ansible.cfg                 # Configuración optimizada (sin bloqueos de host key checking)
│   └── playbooks/                  # Playbooks listos para ejecutar
│       ├── 01_ping_aula.yml        # Test de conectividad en masa
│       ├── 02_sincronizar_reloj.yml# Sincronización horaria (Montevideo)
│       ├── 03_actualizar_paquetes.yml # Actualización de software
│       ├── 04_crear_usuario_alumno.yml# Creación de cuenta alumno
│       ├── 05_apagar_aula.yml      # Apagado simultáneo del aula
│       └── desplegar_perfil_aula.yml # Despliegue completo del Perfil Maestro
└── RegistrarIP/                    # 📁 Directorio central de persistencia
    ├── ips.txt                     # Listado de IPs registradas
    ├── macs.txt                    # Listado de MACs registradas
    ├── perfil_maestro.conf         # Parámetros del Perfil Maestro capturado
    ├── replicar_perfil_autonomo.sh # Script ejecutable autónomo de replicación
    ├── inventario_laboratorio.txt  # Reporte tabulado de equipos descubiertos
    ├── inventario_ansible.ini      # Inventario dinámico generado para Ansible
    ├── remoto.sh                   # Script a distribuir remotamente por el aula
    └── registro_ejecuciones.log    # Historial de ejecuciones SSH
```

---

## 🛠️ Aspectos Técnicos Destacados de Ingeniería

1. **Replicación de Laboratorio sin Clonación de Discos (`ReplicacionAula/`):**
   Permite al docente configurar una sola PC manualmente como "referencia", capturar su estado en un **Perfil Maestro declarativo** y desplegarlo en paralelo a todas las máquinas limpias del aula a través de la red (mediante Ansible o bucle SSH nativo). Configura software pedagógico, cuentas de estudiantes, autologin, zona horaria y hostnames secuenciales sin necesidad de imágenes de 40 GB ni conflictos de drivers.

2. **Aprovisionamiento Express de SSH en Equipos Nuevos (`Red/despliegue_ssh_aula.sh`):**
   * **Servidor HTTP Local (One-Liner):** Inicia un microservidor web en la PC del docente y genera una sola línea (`curl -s http://IP:8080/bootstrap.sh | sudo bash`). Al ejecutarse en las PCs clientes, instala OpenSSH, inyecta la clave pública del profesor y realiza un *callback* registrando la IP, MAC y Hostname en tiempo real en la consola del docente.
   * **Instalador USB Plug & Play (1-Clic):** Genera en un pendrive un lanzador gráfico `.desktop` de doble clic que instala SSH y anota la IP de la máquina en un archivo del pendrive en menos de 5 segundos.

3. **Mapeo de Red y Detección de Hostnames del Aula (`lab1-pcXX`):**
   Escanea la subred local (usando `nmap` de alta velocidad o barrido nativo paralelo en Bash), resuelve direcciones MAC y hostnames mediante DNS inverso y mDNS (`avahi-resolve`), filtra equipos bajo patrones como `lab1-pc*` y realiza un **análisis de secuencia de computadoras**, notificando al docente si alguna máquina intermedia (ej: `lab1-pc03`) está apagada o desconectada.

4. **Asignación Asistida y en Lote de Hostnames (`Red/asignar_hostname.sh`):**
   Permite renombrar la computadora local, un equipo remoto por SSH, o ejecutar una **renombración secuencial masiva** de todo el laboratorio (`lab1-pc01`, `lab1-pc02`...), actualizando simultáneamente `hostnamectl` y `/etc/hosts` para preservar la resolución interna de `sudo`.

5. **Gestión Masiva Automatizada con Ansible:**
   Aprovisiona Ansible y `sshpass` en cualquier distribución, crea la configuración optimizada para laboratorios educativos (`ansible.cfg`) y vincula directamente el inventario generado por el mapeo de red (`inventario_ansible.ini`). Incluye lanzadores para ejecutar playbooks de prueba de red, sincronización de hora, actualización de paquetes, creación de usuarios o apagado conjunto al terminar la clase.

6. **Motor de Detección Multi-Distribución y Capa de Abstracción Universal:**
   Identifica en tiempo de ejecución la familia del sistema operativo (`debian`, `redhat`, `arch`, `suse`), adaptando comandos de paquetes (`apt`, `dnf`, `pacman`, `zypper`), repositorios oficiales y nombres de servicios systemd (`ssh` vs `sshd`, `systemd-timesyncd` vs `chronyd`).

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
