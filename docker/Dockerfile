# syntax=docker/dockerfile:1.4
FROM lscr.io/linuxserver/kasm:latest

LABEL maintainer="BuiltByJonas"
LABEL description="Kasm Workspaces for Pterodactyl"

# Pterodactyl-specific environment
ENV TZ=Europe/Berlin
ARG KASM_PORT=443
ENV KASM_PORT=${KASM_PORT}

# Additional tools
RUN apt-get update && apt-get install -y \
    curl jq uuid-runtime socat \
    && rm -rf /var/lib/apt/lists/*

# ---- 1. SETUP SOCAT RELAY ----
COPY <<-'EOF' /custom-services.d/ptero-api-relay/run
#!/usr/bin/with-contenv bash
echo "[KASM-PETERODACTYL] Forwarding Traffic on :${SERVER_PORT:-443} to Kasm :443"
exec socat TCP-LISTEN:${SERVER_PORT:-443},reuseaddr,fork,bind=0.0.0.0 TCP:127.0.0.1:443
EOF

# ---- 2. SETUP PASSWORD SYNC PYTHON SCRIPT ----
# We place this in /opt instead of the read-only /tmp directory
COPY <<-'EOF' /opt/update_passwords.py
import yaml, psycopg2, time, os, sys
try:
    from passlib.hash import pbkdf2_sha256
except ImportError:
    print("passlib not ready yet!")
    sys.exit(1)

conf_path = '/opt/kasm/current/conf/app/api/app.yaml'
while not os.path.exists(conf_path):
    time.sleep(5)
# Wait additionally for kasm DB to populate default
time.sleep(30)
with open(conf_path, 'r') as f:
    conf = yaml.safe_load(f)
db = conf.get('database', {})
if not db:
    sys.exit(1)
connected = False
for _ in range(60):
    try:
        conn = psycopg2.connect(host=db['host'], port=db.get('port', 5432), database=db['database'], user=db['username'], password=db['password'])
        connected = True
        break
    except Exception as e:
        time.sleep(5)
if not connected:
    print("Could not connect to Kasm Database to sync passwords")
    sys.exit(1)
admin_pass = os.environ.get('ADMIN_PASS', 'password')
user_pass = os.environ.get('USER_PASS', 'password')
cur = conn.cursor()
cur.execute("UPDATE users SET password = %s WHERE username = 'admin@kasm.local'", (pbkdf2_sha256.hash(admin_pass),))
cur.execute("UPDATE users SET password = %s WHERE username = 'user@kasm.local'", (pbkdf2_sha256.hash(user_pass),))
conn.commit()
cur.close()
conn.close()
print("Passwords successfully synced to Pterodactyl allocations.")
EOF

# ---- 3. SETUP PASSWORD SYNC S6 SERVICE ----
COPY <<-'EOF' /custom-services.d/ptero-db-sync/run
#!/usr/bin/with-contenv bash

if [ -f /config/.pterodactyl_passwords_synced ]; then
    echo "[KASM-PETERODACTYL] Passwords synced previously. Skipping."
    exec sleep infinity
fi

echo "[KASM-PETERODACTYL] Waiting for Kasm Installation and Database..."
for i in {1..60}; do
    if [ -f /opt/kasm/current/bin/python3 ]; then
        # Changed to run the statically built script inside /opt
        /opt/kasm/current/bin/python3 /opt/update_passwords.py && touch /config/.pterodactyl_passwords_synced && break
    fi
    sleep 5
done
exec sleep infinity
EOF

# Rootless Pterodactyl & Read-Only Root Fixes
# 1. Symlink /run to /tmp (since Pelican mounts /tmp as a writable tmpfs)
# 2. Tell s6-overlay that it's running in a read-only container root
# 3. Patch out s6-overlay's aggressive /var/run symlink validation since Pelican mounts over it
ENV S6_READ_ONLY_ROOT=1
RUN chmod +x /custom-services.d/ptero-api-relay/run /custom-services.d/ptero-db-sync/run && \
    rm -rf /run && ln -s /tmp /run && \
    mkdir -p /tmp/s6 /tmp/s6-overlay && \
    chown -R 999:999 /tmp /var/log /custom-services.d /opt /etc/s6-overlay || true && \
    sed -i 's|/var/run is not a symlink to /run|SKIPPED PTERO VAR RUN CHECK|g' /package/admin/s6-overlay/libexec/preinit && \
    sed -i 's|rm -rf /var/run||g' /package/admin/s6-overlay/libexec/preinit && \
    sed -i 's|ln -s /run /var/run||g' /package/admin/s6-overlay/libexec/preinit

# Volume for persistant data
VOLUME /config /opt/kasm

# Entry point script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Wrap LSIO init
ENTRYPOINT ["/entrypoint.sh"]