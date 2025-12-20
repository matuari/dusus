# syntax=docker/dockerfile:1
FROM alpine:latest

# Утилиты: jq для безопасной правки JSON, curl/unzip для xray
RUN apk add --no-cache jq curl unzip ca-certificates

# Скачиваем xray
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

# Создаём непривилегированного пользователя
RUN adduser -D -u 10014 choreo_user

# Копируем неизменяемый config.json и entrypoint
COPY config.json /etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
RUN chmod -R 755 /etc/xray

# Переключаемся на непривилегированного пользователя
USER 10014
WORKDIR /etc/xray

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
