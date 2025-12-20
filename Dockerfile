FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates util-linux

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

RUN adduser -D -u 10014 choreo_user

COPY config.json /etc/xray/config.json
RUN chmod 644 /etc/xray/config.json

USER 10014
WORKDIR /etc/xray
EXPOSE 8080

CMD ID="${UUID:-${uuid}}"; \
    if [ -z "$ID" ]; then ID=$(uuidgen); fi; \
    if [ -z "$ID" ]; then ID="00000000-0000-0000-0000-000000000001"; fi; \
    echo "=================================================="; \
    echo "SERVER STARTING WITH UUID: $ID"; \
    echo "=================================================="; \
    sed "s/UUID_PLACEHOLDER/$ID/g" /etc/xray/config.json > /tmp/config.json; \
    exec /usr/bin/xray -config /tmp/config.json
