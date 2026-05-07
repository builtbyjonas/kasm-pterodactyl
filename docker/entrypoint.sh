#!/bin/bash
set -e

echo "[KASM-PETERODACTYL] Startup initiated."
echo "[KASM-PETERODACTYL] Pterodactyl Node Allocation Port: ${SERVER_PORT:-443}"

# 1. SETUP SOCAT RELAY
# This intercepts the Random Pterodactyl Port and bridges it to KASMs native internal 443.
mkdir -p /custom-services.d/ptero-api-relay
cat > /custom-services.d/ptero-api-relay/run << EOF
#!/usr/bin/with-contenv bash
echo "[KASM-PETERODACTYL] Forwarding Traffic on :${SERVER_PORT:-443} to Kasm :443"
exec s6-envuidgid root socat TCP-LISTEN:${SERVER_PORT:-443},reuseaddr,fork,bind=0.0.0.0 TCP:127.0.0.1:443
EOF
chmod +x /custom-services.d/ptero-api-relay/run

# 2. SETUP PASSWORD SYNC
# This runs after Kasm postgres finishes initialization. Wait indefinitely until database is online.
mkdir -p /custom-services.d/ptero-db-sync
cat > /custom-services.d/ptero-db-sync/run << 'EOF'
#!/usr/bin/with-contenv bash

if [ -f /config/.pterodactyl_passwords_synced ]; then
    echo "[KASM-PETERODACTYL] Passwords synced previously. Skipping."
    exec sleep infinity
fi

echo "[KASM-PETERODACTYL] Waiting for Kasm Installation and Database..."

cat > /tmp/update_passwords.py << 'PYEOF'
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
PYEOF

for i in {1..60}; do
    if [ -f /opt/kasm/current/bin/python3 ]; then
        /opt/kasm/current/bin/python3 /tmp/update_passwords.py && touch /config/.pterodactyl_passwords_synced && break
    fi
    sleep 5
done

exec sleep infinity
EOF
chmod +x /custom-services.d/ptero-db-sync/run

# 3. BOOT LSIO
echo "[KASM-PETERODACTYL] Handing over control to LinuxServer Init overlay."
exec /init