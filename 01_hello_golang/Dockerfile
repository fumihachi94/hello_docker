FROM golang:1.13
LABEL maintainer="mjan.share@gmail.com"
LABEL version="0.1"
LABEL description="Docker test."

RUN mkdir /echo
COPY main.go /echo

CMD [ "go", "run", "/echo/main.go" ]