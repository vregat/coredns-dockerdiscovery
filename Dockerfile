FROM golang:1.16.0-buster

RUN go mod download github.com/coredns/coredns@v1.8.1

WORKDIR $GOPATH/pkg/mod/github.com/coredns/coredns@v1.8.1
RUN go mod download

RUN echo "docker:github.com/vregat/coredns-dockerdiscovery" >> plugin.cfg
ENV CGO_ENABLED=0
RUN go generate coredns.go && go build -mod=mod -o=/usr/local/bin/coredns

FROM alpine:3.12.3
LABEL maintainer="dev@comonway.com"

RUN apk --no-cache add ca-certificates
COPY --from=0 /usr/local/bin/coredns /usr/local/bin/coredns

EXPOSE 53 53/udp
VOLUME ["/etc/coredns"]
ENTRYPOINT ["/usr/local/bin/coredns"]
CMD ["-conf", "/etc/coredns/Corefile"]
