FROM golang:tip-alpine3.23
WORKDIR /backend
COPY go.mod ./
COPY go.sum ./
RUN go mod tidy

RUN go install github.com/air-verse/air@latest
ENV PATH="/go/bin:${PATH}"
COPY . .

EXPOSE 8080
CMD ["air"]