# 🧰 Sistema de Automatización y Mantenimiento para Laboratorios Informáticos

**Autor:** Prof. Gabriel Vázquez  
**Ubicación:** Uruguay  
**Profesión:** Profesor de Informática  

---

## 📌 Descripción General

Este proyecto fue creado con el objetivo de **automatizar tareas de mantenimiento, configuración y administración** en los laboratorios de informática, especialmente en entornos educativos. El sistema proporciona un conjunto de scripts Bash diseñados para facilitar al asistente de laboratorio (o al docente responsable) tareas críticas como:

- Configuración de repositorios.
- Sincronización del reloj del sistema mediante NTP.
- Reparación de errores comunes del sistema operativo.
- Registro de direcciones IP.
- Configuración de proxy institucional.
- Interfaz de menú para ejecutar fácilmente cada función.

---

## 📂 Estructura del Proyecto

Una vez descomprimida la carpeta `POITE - Scripts SH`, encontrarás:

```
POITE-Scripts-SH/
├── menu.sh             # Menú de control principal
├── configurar-repos.sh           # Agrega y verifica repositorios oficiales
├── configurar-proxy.sh           # Establece el proxy institucional
├── sincronizar-hora.sh           # Configura zona horaria y sincroniza reloj
├── reparar-sistema.sh            # Realiza mantenimiento completo del sistema
├── registrar-ip.sh               # Guarda la IP del equipo en un archivo
├── README.md                     # Este archivo de ayuda
└── RegistrarIP/ips.txt           # Archivo donde se registran IPs
```

---

## ⚙️ Requisitos

- Ubuntu 20.04 o derivado compatible (Xubuntu, Lubuntu, etc.)
- Acceso de superusuario (`sudo`) para ejecutar configuraciones del sistema.
- Conexión a internet (para actualizaciones, NTP, repositorios).
- Puerto UDP 123 abierto (para sincronización NTP).

---

## 🚀 Instalación y Uso

1. **Descargar y descomprimir** la carpeta `POITE - Scripts SH`.

2. Asignar permisos de ejecución recursivos:

   ```bash
   chmod -R +x "POITE - Scripts SH"
   ```

3. Ingresar al directorio:

   ```bash
   cd "POITE - Scripts SH"
   ```

4. Ejecutar el menú principal:

   ```bash
   ./menu.sh
   ```

5. Desde el menú podrás acceder a cada módulo de mantenimiento de forma interactiva y clara.

---

## 📋 Funcionalidades del Menú

| Opción                      | Función                                                                 |
|----------------------------|-------------------------------------------------------------------------|
| 🛠 Reparar sistema          | Realiza limpieza, actualización, reinstalación y reparación del sistema |
| 🌐 Configurar proxy         | Establece un proxy HTTP/HTTPS institucional                             |
| 🕒 Sincronizar hora         | Configura servidores NTP y zona horaria Uruguay                         |
| 📋 Registrar IP             | Guarda la IP del host en un archivo centralizado                        |
| 📦 Configurar repositorios | Añade y verifica repos oficiales de Ubuntu Focal                        |
| 🔁 Salir                   | Finaliza el script                                                      |

---

## 🛡 Recomendaciones

- **Ejecutar el menú como superusuario** para garantizar permisos adecuados.
- **Probar primero en una máquina virtual** si se aplicarán en múltiples equipos.
- **Sincronizar regularmente** el sistema para mantener las configuraciones actualizadas.

---

## 📬 Contacto

**Gabriel Vázquez**  
Profesor de Informática - Uruguay  
📧 *[gabriel.vazquez@docente.ceibal.edu.uy]*

---

## 🧠 Licencia

Este proyecto puede ser utilizado, adaptado y mejorado por otros docentes o instituciones con fines educativos. Agradezco cualquier colaboración o sugerencia.

---
