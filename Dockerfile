FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

RUN adduser -D -u 10014 choreo_user

COPY config.json /etc/xray/config.json

USER 10014
WORKDIR /tmp

EXPOSE 8080

CMD cp /etc/xray/config.json /tmp/config.json && \
    sed -i "s/UUID_PLACEHOLDER/${UUID}/g" /tmp/config.json && \
    /usr/bin/xray -config /tmp/config.json
