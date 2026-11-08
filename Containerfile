ARG VERSION=v0.41.1

FROM docker.io/freebsd/freebsd-toolchain:15.1 AS builder

ARG VERSION \
      GO_VERSION=1.27.1 \
      GOBIN=/app

RUN set -ex; \
      fetch -o /tmp/go.tar.gz https://dl.google.com/go/go${GO_VERSION}.freebsd-$(uname -m).tar.gz; \
      fetch -o /tmp/go.tar.gz.sha256 https://dl.google.com/go/go${GO_VERSION}.freebsd-$(uname -m).tar.gz.sha256; \
      sha256 -c "$(cat /tmp/go.tar.gz.sha256)" /tmp/go.tar.gz; \
      tar -xzf /tmp/go.tar.gz -C /usr/local; \
      mkdir -p /usr/local/bin; \
      ln -sf /usr/local/go/bin/* /usr/local/bin/
RUN set -ex; \
      env ASSUME_ALWAYS_YES=yes pkg install -y git; \
      mkdir -p /app; \
      env CGO_ENABLED=0 GOPRIVATE=ganigeorgiev.com go install -ldflags "-s -w" ganigeorgiev.com/pocketbase/pocketbase/examples/base@${VERSION}; \
      mv /app/base /app/pocketbase

# podman build --target output -o type=local,dest=./out
FROM scratch AS output
COPY --from=builder /app/ /
