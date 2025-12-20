#!/bin/sh
set -eu

# Проверка формата UUID 8-4-4-4-12 hex (строчные/прописные буквы допускаются)
is_valid_uuid() {
  echo "$1" | grep -Eiq '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
}

# Таймаут ожидания переменной от платформы (в секундах)
WAIT_SECONDS=${WAIT_FOR_UUID_SECONDS:-15}
SLEEP_INTERVAL=1
elapsed=0

# Ждём, если переменная ещё не инжектирована
if [ -n "${UUID:-}" ]; then
  echo "UUID environment variable already set."
else
  echo "UUID not set, waiting up to ${WAIT_SECONDS}s for platform to inject it..."
  while [ $elapsed -lt $WAIT_SECONDS ]; do
    if [ -n "${UUID:-}" ]; then
      echo "UUID received after ${elapsed}s."
      break
    fi
    sleep $SLEEP_INTERVAL
    elapsed=$((elapsed + SLEEP_INTERVAL))
  done
fi

# Если не пришла — выходим с ошибкой
if [ -z "${UUID:-}" ]; then
  echo "ERROR: UUID environment variable is not set after waiting ${WAIT_SECONDS}s." >&2
  echo "Container will exit." >&2
  exit 1
fi

# Валидация формата UUID
if ! is_valid_uuid "$UUID"; then
  echo "ERROR: UUID value '$UUID' is not a valid UUID (expected 8-4-4-4-12 hex)." >&2
  exit 2
fi

echo "UUID: $UUID"

# Подстановка UUID в конфиг (не перезаписываем исходный /etc/xray/config.json)
sed "s/UUID_PLACEHOLDER/$UUID/g" /etc/xray/config.json > /tmp/config.json

# Запускаем xray (exec чтобы процесс стал PID 1)
exec /usr/bin/xray -config /tmp/config.json
