FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

COPY config.json /etc/xray/config.json

RUN chmod -R 777 /etc/xray

WORKDIR /etc/xray

EXPOSE 8080

CMD sed -i "s/UUID_PLACEHOLDER/$UUID/g" /etc/xray/config.json && /usr/bin/xray -config /etc/xray/config.json
