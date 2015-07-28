FROM alpine:3.2

COPY . /work/

ENV PATH /work:$PATH

RUN cd /work && \
    ln -s nsenter-2015-07-28 nsenter && \
    apk update && \
    apk add go=1.4.2-r0 git && \
    apk add ethtool ipfw iptables iproute2 sudo && \
    mkdir -p gopath/src/github.com/tylertreat && \
    ln -s /work/Comcast gopath/src/github.com/tylertreat/Comcast && \
    ln -s /work/Comcast gopath/src/github.com/tylertreat/comcast && \
    export GOPATH=$(pwd)/gopath && \
    \
    cd Comcast && \
    git apply ../docker-comcast.patch && \
    go get -d . && \
    go build . && \
    mv Comcast ../comcast && \
    cd .. && \
    \
    apk del go git && \
    rm -r gopath /var/cache/*

# Needed to make sure the actual application of rules happens
ENTRYPOINT ["/work/nsenter", "--target", "1", "--net", "/work/comcast"]
