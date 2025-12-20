FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates util-linux

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

RUN adduser -D -u 10014 choreo_user

COPY config.json /etc/xray/config.json
RUN chmod -R 755 /etc/xray

RUN touch /tmp/start.sh && chmod +x /tmp/start.sh

RUN echo '#!/bin/sh' >> /tmp/start.sh
RUN echo 'echo "--- STARTING SETUP ---"' >> /tmp/start.sh

RUN echo 'if [ -n "$UUID" ]; then' >> /tmp/start.sh
RUN echo '  MY_ID="$UUID"' >> /tmp/start.sh
RUN echo '  echo "Found Secret: UUID"' >> /tmp/start.sh
RUN echo 'elif [ -n "$uuid" ]; then' >> /tmp/start.sh
RUN echo '  MY_ID="$uuid"' >> /tmp/start.sh
RUN echo '  echo "Found Secret: uuid"' >> /tmp/start.sh
RUN echo 'else' >> /tmp/start.sh
RUN echo '  echo "No secret found. Generating random UUID..."' >> /tmp/start.sh
RUN echo '  MY_ID=$(uuidgen)' >> /tmp/start.sh
RUN echo 'fi' >> /tmp/start.sh

RUN echo 'if [ -z "$MY_ID" ]; then MY_ID="00000000-0000-0000-0000-000000000001"; fi' >> /tmp/start.sh

RUN echo 'echo "========================================="' >> /tmp/start.sh
RUN echo 'echo "CONNECTION UUID: $MY_ID"' >> /tmp/start.sh
RUN echo 'echo "========================================="' >> /tmp/start.sh

RUN echo 'sed "s/UUID_PLACEHOLDER/$MY_ID/g" /etc/xray/config.json > /tmp/config.json' >> /tmp/start.sh
RUN echo 'exec /usr/bin/xray -config /tmp/config.json' >> /tmp/start.sh

USER 10014
WORKDIR /etc/xray
EXPOSE 8080

CMD ["/tmp/start.sh"]
