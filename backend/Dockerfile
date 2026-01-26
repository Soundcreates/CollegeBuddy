FROM golang:tip-alpine3.23
WORKDIR /backend
COPY go.mod ./
COPY go.sum ./
RUN go mod tidy
COPY . .

RUN go build -o main ./cmd/server
EXPOSE 8080
CMD ["./main"]