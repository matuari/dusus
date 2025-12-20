FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates util-linux

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

RUN adduser -D -u 10014 choreo_user

COPY config.json /etc/xray/config.json
RUN chmod -R 755 /etc/xray

RUN cat <<'EOF' > /tmp/start.sh
#!/bin/sh
set -e

echo "--- SETUP START ---"

if [ -n "$UUID" ]; then
  MY_ID="$UUID"
  echo "Using defined Secret: UUID"
elif [ -n "$uuid" ]; then
  MY_ID="$uuid"
  echo "Using defined Secret: uuid"
else
  echo "Secret not found. Generating new UUID via uuidgen..."
  MY_ID=$(uuidgen)
fi

if [ -z "$MY_ID" ]; then
  echo "CRITICAL ERROR: UUID is empty. Generating fallback..."
  MY_ID="00000000-0000-0000-0000-000000000001"
fi

echo "=================================================="
echo "CONNECTION UUID: $MY_ID"
echo "=================================================="

sed "s/UUID_PLACEHOLDER/$MY_ID/g" /etc/xray/config.json > /tmp/config.json

exec /usr/bin/xray -config /tmp/config.json
EOF

RUN chmod +x /tmp/start.sh

USER 10014
WORKDIR /etc/xray
EXPOSE 8080

CMD ["/tmp/start.sh"]
