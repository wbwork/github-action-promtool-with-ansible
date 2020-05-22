FROM golang:alpine as builder

# Set necessary environmet variables needed for our image
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

RUN ["/bin/sh", "-c", "apk add --update --no-cache bash ca-certificates curl git jq openssh sudo"]

# Move to working directory /build
WORKDIR /build

# Copy and download dependency using go mod
COPY . .

RUN go mod download

# Build the application
RUN go build -o main 

# Install promtool
RUN /build/install-promtool.sh

FROM arillso/ansible:2.9.7 as production

# Copy binary from build to main folder
COPY --from=builder /build/main /usr/local/bin/promtool /usr/local/bin/

# Run as root
USER root

# Command to run when starting the container
CMD ["main"]
