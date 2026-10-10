#!/bin/bash
# ==============================================================================
# ASISTENTE POITE - DGES / URUGUAY
# Compatibilidad hacia atrás: Redirección a Mantenimiento/chequear_repositorios.sh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "$SCRIPT_DIR/Mantenimiento/chequear_repositorios.sh" "$@"