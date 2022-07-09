modules = challenge.c
KERNEL_VERSION=5.11.7

vm: binary
	cp flag.txt /kernel-builder/fs/flag
	cp challenge.c /kernel-builder/fs/src
	cd kernel_build && make both

challenge:	#vm
	docker build -t embryo_kernel .

docker:	challenge
	docker run --rm -it embryo_kernel