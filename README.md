# 🖥️ POITE-Scripts-SH-DGES

¡Hola! Soy **Gabriel Vázquez**, profesor de informática en Uruguay. Este proyecto nació de mi experiencia diaria en los laboratorios educativos de la **DGES** (Dirección General de Educación Secundaria), donde busco facilitar el trabajo cotidiano de docentes y POITES de aula.

---

## 📌 Descripción

Desarrollé este **script Bash interactivo** para simplificar la administración de sistemas **GNU/Linux** en los laboratorios. Mi objetivo es que tanto docentes como POITES puedan gestionar tareas comunes de manera más simple y rápida, a través de un menú intuitivo que automatiza acciones como:

- 🌐 **Diagnóstico de red**
- 👥 **Gestión de cuentas de usuario**
- 🧹 **Limpieza y mantenimiento**
- 💻 **Revisión de información del sistema**
- ⚙️ **Accesos rápidos a configuraciones útiles**

> **Objetivo:** Optimizar el trabajo en los laboratorios, brindando una herramienta accesible desde la consola, con una interfaz visual clara (colores y emojis).

---

## 👤 Sobre mí

**Gabriel Vázquez**  
*Profesor de informática – Uruguay*  
[![Email](https://img.shields.io/badge/email-gabriel.vazquez%40docente.ceibal.edu.uy-blue?style=flat-square&logo=gmail)](mailto:gabriel.vazquez@docente.ceibal.edu.uy)

---

## 🎯 Objetivo del proyecto

Facilitar las tareas frecuentes de mantenimiento y administración en los laboratorios informáticos de la **DGES**, permitiendo al personal educativo:

- 🚀 **Agilizar tareas rutinarias**
- ✅ **Minimizar errores de ejecución**
- ⏱️ **Mejorar el tiempo de respuesta ante problemas comunes**
- 🛠️ **Promover la autonomía técnica en la gestión de equipos**

---

## 🗃️ Contenido del proyecto

| Archivo/Carpeta | Descripción                                      |
|:---------------:|:-------------------------------------------------|
| [`menu.sh`](menu.sh) | Script principal con menú interactivo            |
| `.git/`         | Estructura del repositorio Git (control de versiones) |

---

## 📂 Estructura del menú

Al ejecutar <kbd>menu.sh</kbd>, verás un menú principal con las siguientes opciones:

```
1. 🌐 Red y conectividad
2. 👥 Usuarios y cuentas
3. 💻 Información del sistema
4. 🧹 Mantenimiento
5. 🧩 Instalaciones y herramientas
6. 🔧 Herramientas técnicas
7. 📦 Scripts adicionales
8. 🔚 Salir
```

Cada opción abre un submenú o ejecuta tareas automatizadas.

---

## ▶️ Cómo ejecutar

1. **Abrí una terminal.**
2. **Navegá al directorio del script:**
   ```bash
   cd POITE-Scripts-SH-DGES
   ```
3. **Asigná permisos de ejecución (si es necesario):**
   ```bash
   chmod +x menu.sh
   ```
4. **Ejecutá el script:**
   ```bash
   ./menu.sh
   ```

---

## ⚙️ Requisitos

- Sistema operativo: **GNU/Linux** (preferentemente Debian/Ubuntu)
- **Bash shell**
- Permisos de **superusuario** para algunas tareas (ej. creación de usuarios, instalación de software)

---

## 🧪 Ejemplos de funciones incluidas

Incluye funciones como:

- Configurar el proxy de DGES en la terminal
- Comunicación de red entre equipos del laboratorio
- Reparar repositorios y dependencias de paquetes
- Creación de usuarios masivos
- Operaciones en red con SSH por lotes.

---

## 🔐 Seguridad

Este script **no recoge información personal** ni se conecta a servidores externos sin interacción del usuario.  
> **Nota:** Muchas operaciones requieren permisos de root.  
> **Recomendación:** Revisá el código antes de usarlo en entornos productivos.

---

## 🧱 Posibles mejoras futuras

Estoy pensando en agregar:

- Inclusión de logs de ejecución
- Exportación de reportes del sistema
- Modularización en scripts externos por categoría
- Detección automática del entorno (distribución, red, etc.)

---

## 📄 Licencia

Este proyecto se distribuye de forma libre para la colaboración de docentes y POITES que deseen contribuir.

---

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas!  
Si querés sumar mejoras:

1. Hacé un **fork** del repositorio.
2. Creá una **rama**.
3. Subí los cambios con una descripción clara.
4. Abrí un **Pull Request**.

---

## 📬 Contacto

¿Sugerencias, dudas o querés colaborar?  
[![Email](https://img.shields.io/badge/email-gabriel.vazquez%40docente.ceibal.edu.uy-blue?style=flat-square&logo=gmail)](mailto:gabriel.vazquez@docente.ceibal.edu.uy)