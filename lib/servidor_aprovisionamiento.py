#!/usr/bin/env python3
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Servidor HTTP de Aprovisionamiento Dinámico de SSH en el Aula
# ==============================================================================

import sys
import os
import urllib.parse
import http.server
import socketserver
import datetime

PUERTO = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
IP_DOCENTE = sys.argv[2] if len(sys.argv) > 2 else "127.0.0.1"
CLAVE_SSH_PUBLICA = sys.argv[3] if len(sys.argv) > 3 else ""
DIR_DATOS = sys.argv[4] if len(sys.argv) > 4 else "/tmp"

ARCHIVO_IPS = os.path.join(DIR_DATOS, "ips.txt")
ARCHIVO_MACS = os.path.join(DIR_DATOS, "macs.txt")
ARCHIVO_INVENTARIO = os.path.join(DIR_DATOS, "inventario_ansible.ini")
ARCHIVO_REPORTE = os.path.join(DIR_DATOS, "inventario_laboratorio.txt")

GREEN = "\033[0;32m"
CYAN = "\033[0;36m"
YELLOW = "\033[1;33m"
BOLD = "\033[1m"
RESET = "\033[0m"

PLANTILLA_BOOTSTRAP = """#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - CLIENTE DE APROVISIONAMIENTO EXPRESS DE SSH
# ==============================================================================

set -e

echo -e "\\033[1;34m======================================================================\\033[0m"
echo -e "\\033[1;36m   🚀 ASISTENTE POITE · APROVISIONAMIENTO DE SSH EN EL AULA\\033[0m"
echo -e "\\033[1;34m======================================================================\\033[0m"

if [[ $EUID -ne 0 ]]; then
    echo -e "\\033[1;33m⚠️  Este script requiere permisos de administrador (sudo).\\033[0m"
    exec sudo bash "$0" "$@"
fi

echo -e "\\033[0;36m1. Detectando gestor de paquetes de la distribución...\\033[0m"
PKG_CMD=""
if command -v apt-get >/dev/null 2>&1; then
    PKG_CMD="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_CMD="dnf"
elif command -v pacman >/dev/null 2>&1; then
    PKG_CMD="pacman"
elif command -v zypper >/dev/null 2>&1; then
    PKG_CMD="zypper"
fi

echo -e "\\033[0;36m2. Instalando OpenSSH Server ($PKG_CMD)...\\033[0m"
case "$PKG_CMD" in
    apt)
        DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null 2>&1 || true
        DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server >/dev/null 2>&1
        systemctl enable --now ssh >/dev/null 2>&1 || service ssh start >/dev/null 2>&1 || true
        ;;
    dnf)
        dnf install -y openssh-server >/dev/null 2>&1
        systemctl enable --now sshd >/dev/null 2>&1 || true
        ;;
    pacman)
        pacman -Sy --noconfirm openssh >/dev/null 2>&1
        systemctl enable --now sshd >/dev/null 2>&1 || true
        ;;
    zypper)
        zypper install -y openssh >/dev/null 2>&1
        systemctl enable --now sshd >/dev/null 2>&1 || true
        ;;
    *)
        echo "Gestor no reconocido, intentando comando genérico..."
        ;;
esac

echo -e "\\033[0;36m3. Inyectando clave SSH pública del docente para acceso directo...\\033[0m"
CLAVE_PUB="__CLAVE_PUB__"

inyectar_clave() {
    local dir_ssh="$1/.ssh"
    local auth_file="$dir_ssh/authorized_keys"
    mkdir -p "$dir_ssh"
    chmod 700 "$dir_ssh"
    if [[ -n "$CLAVE_PUB" ]]; then
        if ! grep -Fxq "$CLAVE_PUB" "$auth_file" 2>/dev/null; then
            echo "$CLAVE_PUB" >> "$auth_file"
        fi
        chmod 600 "$auth_file"
    fi
}

inyectar_clave "/root"

for home_dir in /home/*; do
    if [[ -d "$home_dir" ]]; then
        user_name=$(basename "$home_dir")
        inyectar_clave "$home_dir"
        chown -R "$user_name:$user_name" "$home_dir/.ssh" 2>/dev/null || true
    fi
done

IFACE=$(ip route 2>/dev/null | awk '/default/ {print $5}' | head -n1 || echo "eth0")
IP_LOCAL=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \\K[0-9.]+' || hostname -I | awk '{print $1}')
MAC_LOCAL=$(cat "/sys/class/net/$IFACE/address" 2>/dev/null || echo "N/A")
HOST_LOCAL=$(hostname)

echo -e "\\033[0;32m✅ OpenSSH Server instalado y activo en puerto 22.\\033[0m"
echo -e "\\033[0;36m4. Notificando registro al servidor central ($IP_LOCAL -> __IP_DOCENTE__)...\\033[0m"

REG_URL="http://__IP_DOCENTE__:__PUERTO__/registro?ip=$IP_LOCAL&host=$HOST_LOCAL&mac=$MAC_LOCAL"
if command -v curl >/dev/null 2>&1; then
    curl -s "$REG_URL" >/dev/null 2>&1 || true
elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$REG_URL" >/dev/null 2>&1 || true
fi

echo -e "\\033[1;32m🎉 ¡Equipo $HOST_LOCAL ($IP_LOCAL) aprovisionado y registrado con éxito!\\033[0m"
"""

PLANTILLA_HTML = """<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asistente POITE - Aprovisionamiento SSH</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 2rem; display: flex; justify-content: center; }
        .card { background: #1e293b; border-radius: 12px; padding: 2rem; max-width: 650px; width: 100%; box-shadow: 0 10px 25px rgba(0,0,0,0.5); border: 1px solid #334155; }
        h1 { color: #38bdf8; font-size: 1.5rem; margin-top: 0; }
        p { color: #94a3b8; line-height: 1.5; }
        .code-box { background: #020617; border: 1px solid #475569; padding: 1rem; border-radius: 8px; font-family: monospace; font-size: 1.1rem; color: #4ade80; word-break: break-all; margin: 1.5rem 0; }
        button { background: #0284c7; color: white; border: none; padding: 0.75rem 1.5rem; font-size: 1rem; border-radius: 6px; cursor: pointer; font-weight: bold; transition: background 0.2s; }
        button:hover { background: #0369a1; }
        .badge { display: inline-block; background: #0369a1; color: white; padding: 0.25rem 0.6rem; border-radius: 4px; font-size: 0.8rem; font-weight: bold; }
    </style>
</head>
<body>
    <div class="card">
        <span class="badge">DGES · ANEP · URUGUAY</span>
        <h1>🚀 Aprovisionamiento Automático de SSH</h1>
        <p>Para activar el servicio SSH en esta computadora e integrarla al laboratorio central del docente, abre una terminal (Ctrl+Alt+T) y pega el siguiente comando:</p>
        
        <div class="code-box" id="cmdText">curl -s http://__IP_DOCENTE__:__PUERTO__/bootstrap.sh | sudo bash</div>
        
        <button onclick="copiarComando()">📋 Copiar Comando al Portapapeles</button>
        <span id="copyMsg" style="margin-left: 1rem; color: #4ade80; display: none;">¡Copiado!</span>

        <p style="margin-top: 2rem; font-size: 0.85rem; color: #64748b;">Prof. Gabriel Vázquez · Gestión de Laboratorios de Informática</p>
    </div>
    <script>
        function copiarComando() {
            const text = document.getElementById('cmdText').innerText;
            navigator.clipboard.writeText(text).then(() => {
                const msg = document.getElementById('copyMsg');
                msg.style.display = 'inline';
                setTimeout(() => msg.style.display = 'none', 2500);
            });
        }
    </script>
</body>
</html>
"""

def generar_bootstrap():
    return PLANTILLA_BOOTSTRAP.replace("__CLAVE_PUB__", CLAVE_SSH_PUBLICA.strip()).replace("__IP_DOCENTE__", IP_DOCENTE).replace("__PUERTO__", str(PUERTO))

def generar_html():
    return PLANTILLA_HTML.replace("__IP_DOCENTE__", IP_DOCENTE).replace("__PUERTO__", str(PUERTO))

class ProvisioningHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        params = urllib.parse.parse_qs(parsed.query)

        if path == "/bootstrap.sh":
            contenido = generar_bootstrap().encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/x-shellscript")
            self.send_header("Content-Length", str(len(contenido)))
            self.end_headers()
            self.wfile.write(contenido)

        elif path == "/registro":
            ip = params.get("ip", ["desconocida"])[0]
            host = params.get("host", ["pc"])[0]
            mac = params.get("mac", ["N/A"])[0]
            ahora = datetime.datetime.now().strftime("%H:%M:%S")

            print(f"\n{GREEN}🎉 [{ahora}] NUEVO EQUIPO REGISTRADO EN EL AULA:{RESET}")
            print(f"   • {BOLD}IP:{RESET}       {CYAN}{ip}{RESET}")
            print(f"   • {BOLD}Hostname:{RESET} {YELLOW}{host}{RESET}")
            print(f"   • {BOLD}MAC:{RESET}      {mac}")

            if ip and ip != "desconocida":
                try:
                    os.makedirs(DIR_DATOS, exist_ok=True)
                    lineas = []
                    if os.path.exists(ARCHIVO_IPS):
                        with open(ARCHIVO_IPS, "r") as f:
                            lineas = [l.strip() for l in f.readlines()]
                    if ip not in lineas:
                        with open(ARCHIVO_IPS, "a") as f:
                            f.write(f"{ip}\n")

                    if mac and mac != "N/A":
                        macs_existentes = []
                        if os.path.exists(ARCHIVO_MACS):
                            with open(ARCHIVO_MACS, "r") as f:
                                macs_existentes = [l.strip() for l in f.readlines()]
                        if mac not in macs_existentes:
                            with open(ARCHIVO_MACS, "a") as f:
                                f.write(f"{mac}\n")

                    if os.path.exists(ARCHIVO_INVENTARIO):
                        with open(ARCHIVO_INVENTARIO, "r") as f:
                            contenido_inv = f.read()
                        if f"ansible_host={ip}" not in contenido_inv:
                            nuevo_item = f"{host} ansible_host={ip}\n"
                            if "[laboratorio]" in contenido_inv:
                                contenido_inv = contenido_inv.replace("[laboratorio]\n", f"[laboratorio]\n{nuevo_item}")
                                with open(ARCHIVO_INVENTARIO, "w") as f:
                                    f.write(contenido_inv)
                except Exception as e:
                    print(f"⚠️ Error al persistir registro: {e}")

            resp = b"OK\n"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(resp)))
            self.end_headers()
            self.wfile.write(resp)

        else:
            contenido = generar_html().encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(contenido)))
            self.end_headers()
            self.wfile.write(contenido)

class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True

def iniciar_servidor():
    with ThreadingHTTPServer(("0.0.0.0", PUERTO), ProvisioningHandler) as httpd:
        print(f"{CYAN}======================================================================{RESET}")
        print(f"{BOLD}${GREEN}   🌐 SERVIDOR DE APROVISIONAMIENTO HTTP ACTIVO EN EL AULA{RESET}")
        print(f"{CYAN}======================================================================{RESET}")
        print(f"   • {BOLD}Dirección local:{RESET} http://{IP_DOCENTE}:{PUERTO}")
        print(f"   • {BOLD}Directorio datos:{RESET} {DIR_DATOS}")
        print(f"\n{BOLD}{YELLOW}👉 Para activar SSH en cualquier PC del laboratorio, ejecute allí:{RESET}")
        print(f"   {GREEN}curl -s http://{IP_DOCENTE}:{PUERTO}/bootstrap.sh | sudo bash{RESET}")
        print(f"\n   (O con wget si no tiene curl):")
        print(f"   {YELLOW}wget -qO- http://{IP_DOCENTE}:{PUERTO}/bootstrap.sh | sudo bash{RESET}")
        print(f"\n   (O abra en el navegador web):")
        print(f"   {CYAN}http://{IP_DOCENTE}:{PUERTO}{RESET}")
        print(f"{CYAN}----------------------------------------------------------------------{RESET}")
        print(f"{BOLD}Esperando conexiones de equipos del aula... (Presione Ctrl+C para salir){RESET}")
        print(f"{CYAN}----------------------------------------------------------------------{RESET}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print(f"\n{YELLOW}Servidor de aprovisionamiento detenido.{RESET}")

if __name__ == "__main__":
    iniciar_servidor()
