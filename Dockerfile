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

CMD ["/bin/sh", "-c", " \
    echo '--- DEBUG START ---'; \
    if [ -n \"$UUID\" ]; then \
        MY_ID=\"$UUID\"; \
        echo 'Using Secret: UUID (uppercase)'; \
    elif [ -n \"$uuid\" ]; then \
        MY_ID=\"$uuid\"; \
        echo 'Using Secret: uuid (lowercase)'; \
    else \
        echo 'Secrets not found. Generating random UUID...'; \
        MY_ID=$(uuidgen); \
    fi; \
    \
    if [ -z \"$MY_ID\" ]; then \
        MY_ID='00000000-0000-0000-0000-000000000001'; \
        echo 'CRITICAL: Generated fallback UUID'; \
    fi; \
    \
    echo '=================================================='; \
    echo \"FINAL UUID: $MY_ID\"; \
    echo '=================================================='; \
    \
    sed \"s/UUID_PLACEHOLDER/$MY_ID/g\" /etc/xray/config.json > /tmp/config.json; \
    \
    echo '--- CONFIG CHECK ---'; \
    grep \"id\" /tmp/config.json; \
    \
    /usr/bin/xray -config /tmp/config.json \
"]
