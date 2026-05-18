FROM golang:1.26.3-alpine AS builder

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG TARGETVARIANT
ARG VERSION=dev

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    build-base \
    git \
    musl-dev \
    sqlite-dev \
    tar \
    unzip \
    yq \
    zip

WORKDIR /src
COPY . .

RUN ./script/fetch-frontends.sh

ENV CGO_ENABLED=1
RUN mkdir -p /out
RUN go build \
    -trimpath \
    -buildvcs=false \
    -tags go_json \
    -ldflags "-s -w -X github.com/nezhahq/nezha/service/singleton.Version=${VERSION}" \
    -o /out/app \
    ./cmd/dashboard

FROM alpine:3.22

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /dashboard
COPY --from=builder /out/app /dashboard/app
COPY ./script/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/dashboard/data"]
EXPOSE 8008
ARG TZ=Asia/Shanghai
ENV TZ=$TZ
ENTRYPOINT ["/entrypoint.sh"]
