FROM ubuntu:24.04

# Install dependencies

RUN apt-get update && apt-get upgrade && apt-get install -y debsigs debsig-verify debdelta gpg

VOLUME /build
COPY ./build-foo.sh /build-foo.sh

CMD ["/build-foo.sh"]