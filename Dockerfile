FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates util-linux

RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/bin/xray

RUN adduser -D -u 10014 choreo_user

COPY config.json /etc/xray/config.json
RUN chmod -R 755 /etc/xray
RUN printf '#!/bin/sh\n\
\n\
if [ -n "$UUID" ]; then\n\
  MY_ID="$UUID"\n\
  echo "Found Secret: UUID (uppercase)"\n\
elif [ -n "$uuid" ]; then\n\
  MY_ID="$uuid"\n\
  echo "Found Secret: uuid (lowercase)"\n\
else\n\
  echo "Warning: No secret found. Generating random UUID..."\n\
  MY_ID=$(uuidgen)\n\
fi\n\
\n\
if [ -z "$MY_ID" ]; then\n\
  MY_ID="00000000-0000-0000-0000-000000000001"\n\
fi\n\
\n\
echo "========================================="\n\
echo "CONNECTION UUID: $MY_ID"\n\
echo "========================================="\n\
\n\
sed "s/UUID_PLACEHOLDER/$MY_ID/g" /etc/xray/config.json > /tmp/config.json\n\
exec /usr/bin/xray -config /tmp/config.json\n' > /tmp/start.sh && \
chmod +x /tmp/start.sh

USER 10014
WORKDIR /etc/xray
EXPOSE 8080

CMD ["/tmp/start.sh"]
