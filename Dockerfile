FROM alpine:3.2

COPY . /work/

RUN cd /work && \
    apk update && \
    apk add go=1.4.2-r0 git && \
    apk add ethtool ipfw iptables iproute2 sudo && \
    mkdir -p gopath/src/github.com/tylertreat && \
    ln -s $(pwd)/comcast gopath/src/github.com/tylertreat/ && \
    export GOPATH=$(pwd)/gopath && \
    \
    cd comcast && \
    patch <../docker-comcast.patch && \
    go get -d . && \
    go build . && \
    cd .. && \
    \
    apk del go git && \
    rm -r gopath /var/cache/* && \
    \
    ln -s $(pwd)/nsenter-2015-07-28 /usr/bin/nsenter && \
    ln -s $(pwd)/findveth.sh        /usr/bin/ && \
    ln -s $(pwd)/comcast/comcast    /usr/bin/

# Needed to make sure the actual application of rules happens
ENTRYPOINT ["nsenter", "--target", "1", "--net", "comcast"]
