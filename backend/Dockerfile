FROM golang:1.24-alpine AS builder
WORKDIR /backend

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/main ./cmd/server

FROM alpine:3.21
WORKDIR /app

COPY --from=builder /app/main ./main

ENV PORT=8080
EXPOSE 8080

CMD ["./main"]