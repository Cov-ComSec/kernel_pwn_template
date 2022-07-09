#!/bin/bash 

make_kernel()
{
    # ============================= download and extract linux kernel =============================
    if [ -d $BUILD_DIR/linux-$KERNEL_VERSION ]
    then 
        echo "kernel directory exists. Skipping"
    else 
        curl https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VERSION.tar.xz -o $BUILD_DIR/linux-$KERNEL_VERSION.tar.xz
        tar xvJf $BUILD_DIR/linux-$KERNEL_VERSION.tar.xz -C $BUILD_DIR
        rm $BUILD_DIR/linux-$KERNEL_VERSION.tar.xz
    fi

    # ============================= download and extract busybox ====================================
    if [ -d $BUILD_DIR/busybox-1.32.1 ]
    then 
        echo "kernel directory exists. Skipping"
    else 
        curl https://busybox.net/downloads/busybox-1.32.1.tar.bz2 -o $BUILD_DIR/busybox-1.32.1.tar.bz2
        tar xvjf $BUILD_DIR/busybox-1.32.1.tar.bz2 -C $BUILD_DIR
        rm $BUILD_DIR/busybox-1.32.1.tar.bz2
    fi

    # ============================= build userland ==================================================
    echo $'\e[1;33m'Configuring Busybox$'\e[0m'
    cd /$BUILD_DIR/busybox-1.32.1
    mkdir -pv ../obj/busybox-x86
    make O=../obj/busybox-x86 defconfig
    cd ../obj/busybox-x86
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' .config

    echo $'\e[1;33m'Building Busybox$'\e[0m'
    make -j$(nproc)
    make install

    # ============================= build kernel =========================================================
    echo $'\e[1;33m'Configuring Kernel Build$'\e[0m'
    cd /$BUILD_DIR/linux-5.11.7
    make O=../obj/linux-x86-basic x86_64_defconfig
    make O=../obj/linux-x86-basic kvm_guest.config

    cd ../obj/linux-x86-basic
    for CONFIG in \
        CONFIG_9P_FS=y \
        CONFIG_9P_FS_POSIX_ACL=y \
        CONFIG_9P_FS_SECURITY=y \
        CONFIG_BALLOON_COMPACTION=y \
        CONFIG_CRYPTO_DEV_VIRTIO=y \
        CONFIG_DEBUG_FS=y \
        CONFIG_DEBUG_INFO=y \
        CONFIG_DEBUG_INFO_BTF=n \
        CONFIG_DEBUG_INFO_DWARF4=y \
        CONFIG_DEBUG_INFO_REDUCED=n \
        CONFIG_DEBUG_INFO_SPLIT=n \
        CONFIG_DEBUG_INFO_COMPRESSED=n \
        CONFIG_DEVPTS_FS=y \
        CONFIG_DRM_VIRTIO_GPU=y \
        CONFIG_FRAME_POINTER=y \
        CONFIG_GDB_SCRIPTS=y \
        CONFIG_HW_RANDOM_VIRTIO=y \
        CONFIG_HYPERVISOR_GUEST=y \
        CONFIG_NET_9P=y \
        CONFIG_NET_9P_DEBUG=n \
        CONFIG_NET_9P_VIRTIO=y \
        CONFIG_PARAVIRT=y \
        CONFIG_PCI=y \
        CONFIG_PCI_HOST_GENERIC=y \
        CONFIG_VIRTIO_BALLOON=y \
        CONFIG_VIRTIO_BLK=y \
        CONFIG_VIRTIO_BLK_SCSI=y \
        CONFIG_VIRTIO_CONSOLE=y \
        CONFIG_VIRTIO_INPUT=y \
        CONFIG_VIRTIO_NET=y \
        CONFIG_VIRTIO_PCI=y \
        CONFIG_VIRTIO_PCI_LEGACY=y 
    do 
        VAR=$(echo $CONFIG | cut -d'=' -f1)
        isInFile=$(grep -c "$VAR" .config)
        if [ $isInFile -eq 0 ]; then
            echo "$CONFIG" >> .config
        else
            sed -i "s/# $VAR is not set/$CONFIG/g" .config 
            sed -i "s/$VAR=n/$CONFIG/g" .config 
            sed -i "s/$VAR=y/$CONFIG/g" .config 
        fi

    done
        # echo $CONFIG >> .config; done

    echo $'\e[1;33m'Building Kernel$'\e[0m'
    cd /$BUILD_DIR/linux-5.11.7
    make O=../obj/linux-x86-basic -j$(nproc)
}

make_challenge()
{
    # ============================= build kmods =================================
    echo $'\e[1;33m'Building Modules$'\e[0m'
    cd /src
    make kmod
    cp *.ko /fs

    # ============================= build fs =====================================
    echo $'\e[1;33m'Building Filesystem$'\e[0m'
    cd /fs 
    mkdir -p bin etc proc sys dev home/ctf
    chmod +x init

    mkdir -pv /$BUILD_DIR/initramfs/x86-busybox
    cd /$BUILD_DIR/initramfs/x86-busybox
    cp -avR /fs/* .
    cp -av /$BUILD_DIR/obj/busybox-x86/_install/* .

    echo """#!/bin/sh

    mount -t proc none /proc
    mount -t sysfs none /sys
    # mknod -m 666 /dev/ttyS0 c 4 64

    sysctl -w kernel.perf_event_paranoid=1

    insmod /challenge.ko

    echo -e '\nBoot took $(cut -d' ' -f1 /proc/uptime) seconds\n'

    chmod 600 /flag
    chown 0.0 /flag

    # setsid  cttyhack sh

    echo 'Press CTL+] to exit the vm'

    su -l ctf
    """ > /$BUILD_DIR/initramfs/x86-busybox/init
    chmod +x /$BUILD_DIR/initramfs/x86-busybox/init

    # ============================= Bundle fs =================================
    cd /$BUILD_DIR/initramfs/x86-busybox
    find . -print0 \
        | cpio --null -ov --format=newc \
        | gzip -9 > /$BUILD_DIR/obj/initramfs-busybox-x86.cpio.gz
}


if [ $MAKE_KERNEL == "true" ]
then
    make_kernel
fi

if [ $MAKE_CHALLENGE == "true" ]
then
    make_challenge
fi