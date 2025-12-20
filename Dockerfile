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

# CMD sed "s/UUID_PLACEHOLDER/${UUID:-${uuid}}/g" /etc/xray/config.json > /tmp/config.json && /usr/bin/xray -config /tmp/config.json
RUN echo -e '#!/bin/sh\n\
echo "--- DEBUG START ---"\n\
if [ -n "$UUID" ]; then\n\
  MY_ID="$UUID"\n\
  echo "Found variable: UUID (uppercase)"\n\
elif [ -n "$uuid" ]; then\n\
  MY_ID="$uuid"\n\
  echo "Found variable: uuid (lowercase)"\n\
else\n\
  echo "ERROR: UUID variable is empty!"\n\
  exit 1\n\
fi\n\
echo "SERVER PASSWORD IS: $MY_ID"\n\
echo "--- DEBUG END ---"\n\
sed "s/UUID_PLACEHOLDER/$MY_ID/g" /etc/xray/config.json > /tmp/config.json\n\
/usr/bin/xray -config /tmp/config.json' > /tmp/start.sh && chmod +x /tmp/start.sh

CMD ["/tmp/start.sh"]
