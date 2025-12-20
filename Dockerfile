FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

RUN adduser -D -u 10014 choreo_user

COPY config.json /etc/xray/config.json
RUN chmod -R 755 /etc/xray

RUN echo '#!/bin/sh' > /tmp/start.sh && \
    echo 'echo "--- STARTING XRAY SETUP ---"' >> /tmp/start.sh && \
    echo 'if [ -n "$UUID" ]; then' >> /tmp/start.sh && \
    echo '  MY_ID="$UUID"' >> /tmp/start.sh && \
    echo '  echo "Found Secret: UUID (uppercase)"' >> /tmp/start.sh && \
    echo 'elif [ -n "$uuid" ]; then' >> /tmp/start.sh && \
    echo '  MY_ID="$uuid"' >> /tmp/start.sh && \
    echo '  echo "Found Secret: uuid (lowercase)"' >> /tmp/start.sh && \
    echo 'else' >> /tmp/start.sh && \
    echo '  echo "WARNING: No Secret found! Generating temporary UUID..."' >> /tmp/start.sh && \
    echo '  MY_ID=$(cat /proc/sys/kernel/random/uuid)' >> /tmp/start.sh && \
    echo 'fi' >> /tmp/start.sh && \
    echo 'echo "========================================="' >> /tmp/start.sh && \
    echo 'echo "USE THIS UUID IN YOUR CLIENT:"' >> /tmp/start.sh && \
    echo 'echo "$MY_ID"' >> /tmp/start.sh && \
    echo 'echo "========================================="' >> /tmp/start.sh && \
    echo 'sed "s/UUID_PLACEHOLDER/$MY_ID/g" /etc/xray/config.json > /tmp/config.json' >> /tmp/start.sh && \
    echo '/usr/bin/xray -config /tmp/config.json' >> /tmp/start.sh && \
    chmod +x /tmp/start.sh

USER 10014
WORKDIR /etc/xray
EXPOSE 8080

CMD ["/tmp/start.sh"]
