FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

RUN adduser -D -u 10014 choreo_user

COPY config.json /etc/xray/config.json
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 755 /usr/local/bin/entrypoint.sh && \
    chmod -R 755 /etc/xray

USER 10014
WORKDIR /etc/xray

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
