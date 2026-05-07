FROM lscr.io/linuxserver/kasm:latest

LABEL maintainer="BuiltByJonas"
LABEL description="Kasm Workspaces for Pterodactyl"

# Pterodactyl-specific environment
ENV PUID=1000
ENV PGID=1000
ENV TZ=Europe/Berlin
ARG KASM_PORT=443
ENV KASM_PORT=${KASM_PORT}

# Additional tools
RUN apt-get update && apt-get install -y \
    curl jq uuid-runtime socat \
    && rm -rf /var/lib/apt/lists/*

# Volume for persistant data
VOLUME /config /opt/kasm

# Entry point script
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Wrap LSIO init
ENTRYPOINT ["/entrypoint.sh"]