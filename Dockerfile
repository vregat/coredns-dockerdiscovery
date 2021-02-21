FROM golang:1.16.0-buster

RUN go mod download github.com/coredns/coredns@v1.8.1

WORKDIR $GOPATH/pkg/mod/github.com/coredns/coredns@v1.8.1
RUN go mod download

RUN echo "docker:github.com/sywide/coredns-dockerdiscovery" >> plugin.cfg
ENV CGO_ENABLED=0
RUN go generate coredns.go && go build -mod=mod -o=/usr/local/bin/coredns

FROM alpine:3.13.3

RUN apk --no-cache add ca-certificates
COPY --from=0 /usr/local/bin/coredns /usr/local/bin/coredns

ENTRYPOINT ["/usr/local/bin/coredns"]