#!/usr/bin/env bash

#Cleanup old bb table
#sudo rm -f bbtable.qemu

#Cleanup backend file (until this is fixed)
#dd if=/dev/zero of=block_rocks bs=1G count=2 iflag=fullblock
# -device nvme,drive=mynvme,serial=deadbeef,namespaces=1,lver=1,ll2pmode=0,nlbaf=5,lba_index=3,mdts=10,lbbtable=bbtable.qemu \
# -device nvme,drive=mynvme,serial=deadbeef,namespaces=1,lver=1,ll2pmode=0,nlbaf=5,lba_index=3,mdts=10,lnum_lun=4,lsec_size=4096,lsecs_per_pg=4,lpgs_per_blk=64,lbbtable=bbtable.qemu \
#sleep 1

# Removed these: ll2pmode=0,lnum_lun=4,lsec_size=4096,lsecs_per_pg=4,lpgs_per_blk=64,lbbtable=bbtable.qemu
# And the flag: -s
# And some from append: null_blk.nr_devices=1 null_blk.submit_queues=1 null_blk.queue_mode=2 null_blk.lightnvm_enable=1 null_blk.gb=2 null_blk.bs=4096 null_blk.lightnvm_num_channels=1

WORKSPACE="$HOME/sheath/workspace/liblnvm"

QEMU_BIN="$WORKSPACE/qemu/x86_64-softmmu/qemu-system-x86_64"

#CPU="-cpu host"    # This option might break with liblightnvm
MEM="-m 16G"
SMP="-smp 4"

OS_DRIVE="-drive file=$WORKSPACE/images/ubuntu1510_amd64.img,id=diskdrive,format=raw,if=none"
OS_DEVICE="-device virtio-blk-pci,drive=diskdrive,scsi=off,config-wce=off,x-data-plane=on"

NVME_DRIVE="-drive file=$WORKSPACE/images/blknvme,if=none,id=mynvme"
NVME_DEVICE="-device nvme,drive=mynvme,serial=deadbeef,namespaces=1,lver=1,nlbaf=5,lba_index=3,mdts=10"

VIRTFS="-virtfs local,path=$WORKSPACE,security_model=passthrough,id=host0,mount_tag=host0"

PORT_FWD="-net user,hostfwd=tcp::10022-:22 -net nic"

sudo $QEMU_BIN --enable-kvm \
$CPU $MEM $SMP \
$OS_DRIVE $OS_DEVICE \
$NVME_DRIVE $NVME_DEVICE \
-kernel "$WORKSPACE/linux/arch/x86_64/boot/bzImage" \
-append "root=/dev/vda1 null_blk.gb=1 null_blk.use_lightnvm=1 vga=0 console=ttyS0,kgdboc=ttyS1,115200 " \
-serial mon:stdio \
-redir tcp:2022::22 \
-serial pty \
-s \
-nographic \
-chardev socket,id=qmp,path=/tmp/test.qmp,server,nowait \
-mon chardev=qmp,mode=control \
$VIRTFS \
$PORT_FWD
