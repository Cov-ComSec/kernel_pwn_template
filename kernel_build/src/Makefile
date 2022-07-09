obj-m = challenge.o

kmod:
	echo $(OBJECTS)
	make KCFLAGS+='-fno-stack-protector -g' -C /linux-builder/obj/linux-x86-basic M=$(PWD) modules