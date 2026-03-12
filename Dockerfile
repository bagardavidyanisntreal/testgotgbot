# ЭТАП 1: Сборка (Builder)
FROM golang:1.23-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы зависимостей и скачиваем их (для кэширования)
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код и собираем бинарный файл
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/main.go

# ЭТАП 2: Запуск (Final)
FROM alpine:latest

# Добавляем сертификаты для работы по HTTPS и часовые пояса
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /root/

# Копируем только скомпилированный файл из этапа сборки
COPY --from=builder /app/main .

# Указываем порт, который слушает приложение
EXPOSE 8080

# Запуск приложения
CMD ["./main"]
