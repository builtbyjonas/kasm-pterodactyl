#!/bin/bash
set -e

echo "[KASM-PETERODACTYL] Startup initiated."
echo "[KASM-PETERODACTYL] Pterodactyl Node Allocation Port: ${SERVER_PORT:-443}"

# BOOT LSIO
echo "[KASM-PETERODACTYL] Handing over control to LinuxServer Init overlay."
exec /init