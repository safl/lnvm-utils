WORKSPACE=$(HOME)/sheath/workspace/liblnvm
QEMU_BIN=$(WORKSPACE)/qemu/x86_64-softmmu/qemu-system-x86_64
MEM=-m 16G
SMP=-smp 4

DISK_DRIVE=-drive file="$(WORKSPACE)/images/ubuntu1510_amd64.img",id=diskdrive,format=raw,if=none
DISK_DEVICE=-device virtio-blk-pci,drive=diskdrive,scsi=off,config-wce=off,x-data-plane=on

NVME_DRIVE=-drive file="$(WORKSPACE)/images/blknvme",id=mynvme,if=none
#NVME_DEVICE=-device nvme,drive=mynvme,serial=deadbeef,namespaces=1,lver=1,nlbaf=5,lba_index=3,mdts=10,lbbtable=bbtable.qemu
NVME_DEVICE=-device nvme,drive=mynvme,serial=deadbeef,namespaces=1,lver=1,nlbaf=5,lba_index=3,mdts=10

NETWORK=-netdev user,id=user.0 -device e1000,netdev=user.0

KERNEL=-kernel "$(WORKSPACE)/linux/arch/x86_64/boot/bzImage" -append "console=ttyS0,kgdboc=ttyS1,115200 root=/dev/vda1 null_blk.gb=1 null_blk.use_lightnvm=1 vga=0"
MISC=-serial mon:stdio -redir tcp:2022::22 -cpu host -serial pty -s -nographic
CHARDEV=-chardev socket,id=qmp,path=/tmp/test.qmp,server,nowait -mon chardev=qmp,mode=control

VIRTFS=-virtfs local,path="$(WORKSPACE)",security_model=passthrough,id=host0,mount_tag=host0

all: kill run connect

kill:
	-sudo pkill -f qemu-system-x86_64

run:
	sudo $(QEMU_BIN) --enable-kvm $(MEM) $(SMP) $(DISK_DRIVE) $(DISK_DEVICE) $(NVME_DRIVE) $(NVME_DEVICE) $(KERNEL) $(MISC) $(CHARDEV) $(VIRTFS) $(NETWORK)

