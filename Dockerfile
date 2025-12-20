FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

RUN adduser -D -u 10014 choreo_user

COPY config.json /etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh

RUN chown -R 10014:10014 /etc/xray && \
    chmod -R 777 /etc/xray && \
    chmod +x /entrypoint.sh && \
    chown 10014:10014 /tmp && \
    chmod 1777 /tmp

USER 10014
WORKDIR /etc/xray

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
