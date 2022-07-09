FROM debian:latest

RUN apt-get update && \
        apt-get install -yq bc bison build-essential cpio flex libelf-dev libncurses-dev libssl-dev nano python3 curl

COPY build_kernel.sh /

RUN chmod +x /build_kernel.sh 

COPY fs /fs
COPY src /src

ENTRYPOINT [ "/build_kernel.sh" ]