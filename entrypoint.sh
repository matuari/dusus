#!/bin/sh

# Проверяем что UUID установлен
if [ -z "$UUID" ]; then
    echo "ERROR: UUID environment variable is not set!"
    exit 1
fi

echo "UUID is set: ${UUID:0:8}..."

# Заменяем placeholder на реальный UUID
sed -i "s/UUID_PLACEHOLDER/$UUID/g" /etc/xray/config.json

# Запускаем Xray
exec /usr/bin/xray -config /etc/xray/config.json
