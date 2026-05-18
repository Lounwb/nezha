FROM alpine:3.22

ARG TARGETARCH=amd64

RUN apk add --no-cache ca-certificates tzdata curl unzip sqlite

WORKDIR /dashboard

RUN case "$TARGETARCH" in \
      amd64) BIN_ARCH=amd64 ;; \
      arm64) BIN_ARCH=arm64 ;; \
      *) echo "unsupported arch: $TARGETARCH" && exit 1 ;; \
    esac && \
    curl -fsSL -o /tmp/nezha.zip "https://github.com/nezhahq/nezha/releases/latest/download/dashboard-linux-${BIN_ARCH}.zip" && \
    unzip /tmp/nezha.zip -d /dashboard && \
    if [ ! -f /dashboard/app ] && [ -f "/dashboard/dashboard-linux-${BIN_ARCH}" ]; then mv "/dashboard/dashboard-linux-${BIN_ARCH}" /dashboard/app; fi && \
    rm -f /tmp/nezha.zip && \
    chmod +x /dashboard/app

COPY ./script/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/dashboard/data"]
EXPOSE 8008
ARG TZ=Asia/Shanghai
ENV TZ=$TZ
ENTRYPOINT ["/entrypoint.sh"]
