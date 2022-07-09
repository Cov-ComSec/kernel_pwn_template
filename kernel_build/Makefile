.DEFAULT_GOAL := challenge

BUILD_DIR=linux-builder
KERNEL_VERSION=5.11.7

challenge: 
	mkdir -vp $(BUILD_DIR) 

	# build docker and mount to kernel build dir and the binary
	docker build . -t linux-builder
	docker run --rm  --name build -ti -v $(shell pwd)/$(BUILD_DIR):/$(BUILD_DIR) \
	-e KERNEL_VERSION=$(KERNEL_VERSION) -e BUILD_DIR=$(BUILD_DIR) -e MAKE_KERNEL=true -e MAKE_CHALLENGE=true linux-builder

	stty intr ^]
	cd linux-builder && /usr/bin/qemu-system-x86_64 \
		-kernel obj/linux-x86-basic/arch/x86/boot/bzImage \
		-initrd obj/initramfs-busybox-x86.cpio.gz \
		-nographic \
		-monitor none \
		-s \
		-smp 2 \
		-append "console=ttyS0 nokaslr"

kernel:
	mkdir -vp $(BUILD_DIR) 

	# build docker and mount to kernel build dir
	docker build . -t linux-builder
	docker run --rm  --name build -ti -v $(shell pwd)/$(BUILD_DIR):/$(BUILD_DIR) \
	-e KERNEL_VERSION=$(KERNEL_VERSION) -e BUILD_DIR=$(BUILD_DIR) -e MAKE_KERNEL=true -e MAKE_CHALLENGE=false linux-builder

environment:
	docker run -d --rm --name build -ti -v $(shell pwd)/$(BUILD_DIR):/$(BUILD_DIR) \
	-e KERNEL_VERSION=$(KERNEL_VERSION) -e BUILD_DIR=$(BUILD_DIR) -e MAKE_KERNEL=false -e MAKE_CHALLENGE=true --entrypoint=/bin/bash linux-builder 
	
	docker cp src/challenge.c build:/src/challenge.c 
	docker exec  -it  build /build_kernel.sh
	
	stty intr ^]
	cd linux-builder && /usr/bin/qemu-system-x86_64 \
		-kernel obj/linux-x86-basic/arch/x86/boot/bzImage \
		-initrd obj/initramfs-busybox-x86.cpio.gz \
		-nographic \
		-monitor none \
		-s \
		-smp 2 \
		-append "console=ttyS0 nokaslr"

