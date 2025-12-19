FROM alpine:latest

# 1. Обновляем репозитории (вывод поможет понять, есть ли сеть)
RUN apk update

# 2. Устанавливаем инструменты по отдельности
RUN apk add --no-cache curl
RUN apk add --no-cache unzip
RUN apk add --no-cache ca-certificates

# 3. Создаем папку для xray
RUN mkdir -p /etc/xray

# 4. Скачиваем Xray. Используем флаг -v (verbose) и -L (follow redirect)
# Если ссылка не работает, curl выдаст ошибку здесь.
RUN curl -L -v -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip

# 5. ПРОВЕРКА: Показываем размер скачанного файла. 
# Если файл 0 байт или его нет, сборка упадет здесь.
RUN ls -lh /tmp/xray.zip

# 6. Распаковываем в /usr/bin
RUN unzip /tmp/xray.zip -d /usr/bin/

# 7. Чистим и даем права на исполнение
RUN rm /tmp/xray.zip
RUN chmod +x /usr/bin/xray

# 8. Проверяем, что бинарник xray действительно там
RUN ls -la /usr/bin/xray

# 9. Копируем конфиг. 
# ЕСЛИ config.json НЕТ В КОРНЕ РЕПОЗИТОРИЯ, СБОРКА УПАДЕТ ТУТ.
COPY config.json /etc/xray/config.json

# 10. Проверяем, скопировался ли конфиг
RUN ls -la /etc/xray/config.json

# 11. Даем полные права (777) для работы в Choreo
RUN chmod -R 777 /etc/xray
RUN chmod 777 /usr/bin/xray

# Настройка запуска
WORKDIR /etc/xray
EXPOSE 8080

CMD sed -i "s/UUID_PLACEHOLDER/$UUID/g" /etc/xray/config.json && /usr/bin/xray -config /etc/xray/config.json
