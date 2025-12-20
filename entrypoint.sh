#!/bin/sh
set -eu

# WARNING: вывод секретов в логах небезопасен. Удалите echo перед деплоем в production.

# Показать значение переменной для проверки
echo "Runtime check: UUID=${UUID:-not set}"

# Обязательная проверка: если UUID не задан — прекращаем запуск
if [ -z "${UUID:-}" ]; then
  echo "ERROR: UUID is not set. Aborting startup."
  exit 1
fi

# Проверяем наличие исходного конфига
if [ ! -f /etc/xray/config.json ]; then
  echo "ERROR: /etc/xray/config.json not found"
  exit 1
fi

# Создаём временный конфиг, заменяя все вхождения строки UUID_PLACEHOLDER на значение переменной
# Используем jq с рекурсивной функцией walk для безопасной замены в любом месте JSON
jq --arg uuid "$UUID" '
  def walk(f):
    . as $in
    | if type == "object" then
        reduce keys[] as $k ({}; . + { ($k): ($in[$k] | walk(f)) }) | f
      elif type == "array" then
        map( . | walk(f) ) | f
      else
        f
      end;
  def replace_uuid:
    if type == "string" and . == "UUID_PLACEHOLDER" then $uuid else . end;
  walk(replace_uuid)
' /etc/xray/config.json > /tmp/config.json

# Проверка: вывести поле id из сгенерированного конфига (покажет, что подстановка прошла)
echo "Config snippet (id field):"
jq -r '
  # пытаемся найти первое вхождение clients[].id
  (.inbounds[]?.settings?.clients[]?.id) // empty
' /tmp/config.json | head -n 1 || true

# Запускаем xray как PID 1
exec /usr/bin/xray -config /tmp/config.json
