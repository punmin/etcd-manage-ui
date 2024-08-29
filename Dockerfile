FROM node:10 AS builder

WORKDIR /app

COPY package.json .

RUN npm config set registry https://mirrors.cloud.tencent.com/npm/ --global \
    && wget -P /tmp https://repo.huaweicloud.com/nodejs/v10.24.1/node-v10.24.1-headers.tar.gz \
    && npm config set tarball /tmp/node-v10.24.1-headers.tar.gz \
    && npm install

COPY . .

RUN make build

FROM golang:1.14

WORKDIR /app
 
ENV GOPROXY "https://mirrors.tencent.com/go/"

RUN go get -u github.com/jteeuwen/go-bindata/...

COPY --from=builder /app/dist ./dist

RUN go-bindata -o tpls.go dist/... \
    && sed -i "s/package main/package tpls/g" tpls.go
