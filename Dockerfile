FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

RUN adduser -D -u 10014 choreo_user

COPY config.json /etc/xray/config.json

RUN chmod -R 755 /etc/xray

USER 10014
WORKDIR /etc/xray

EXPOSE 8080

CMD \
  echo "UUID: ${UUID:-not set}" && \
  echo "uuid: ${uuid:-not set}" && \
  sed "s/UUID_PLACEHOLDER/$UUID/g" /etc/xray/config.json > /tmp/config.json && \
  exec /usr/bin/xray -config /tmp/config.json
