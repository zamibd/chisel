# 🏗️ Build stage
FROM golang:alpine AS build

# Install git for version injection
RUN apk add --no-cache git

# Copy source code
WORKDIR /src
COPY . .

# Disable CGO for static binary
ENV CGO_ENABLED=0

# Build with version info from latest tag
RUN go build \
  -ldflags "-X github.com/jpillora/chisel/share.BuildVersion=$(git describe --tags --abbrev=0)" \
  -o /tmp/bin

# 🚀 Run stage
FROM scratch

LABEL maintainer="hi@imzami.com"

# Copy CA certificates for HTTPS support
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy binary
WORKDIR /app
COPY --from=build /tmp/bin /app/bin

# Run the binary
ENTRYPOINT ["/app/bin"]
