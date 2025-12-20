#!/bin/sh

echo "=== Starting entrypoint ==="
echo "Current directory: $(pwd)"
echo "Checking UUID variable..."

# Проверяем что UUID установлен
if [ -z "$UUID" ]; then
    echo "ERROR: UUID environment variable is not set!"
    echo "Available environment variables:"
    env | grep -i uuid || echo "No UUID-related vars found"
    exit 1
fi

echo "UUID is set: ${UUID:0:8}..."

# Копируем конфиг в /tmp/ (куда Choreo ожидает его)
cp /etc/xray/config.json /tmp/config.json

# Заменяем placeholder на реальный UUID
sed -i "s/UUID_PLACEHOLDER/$UUID/g" /tmp/config.json

echo "Config prepared in /tmp/config.json"
echo "Starting Xray..."

# Запускаем Xray с конфигом в /tmp/
exec /usr/bin/xray -config /tmp/config.json
