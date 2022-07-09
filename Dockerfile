FROM ubuntu:20.04

RUN apt update && apt install -qy --no-install-recommends openssh-server openssh-client nano curl python3 vim qemu qemu-kvm

RUN useradd -rm -d /home/ctf -s /bin/bash -u 1337 ctf && \
    echo ctf:password | chpasswd && \
    service ssh start 

EXPOSE 2222

CMD ["/usr/sbin/sshd", "-D"]