lzop

Kernel for host
===============

Install Linux 4.4.3::

    cd /tmp
    wget \
    kernel.ubuntu.com/~kernel-ppa/mainline/v4.4.3-wily/linux-headers-4.4.3-040403_4.4.3-040403.201602251634_all.deb \
    kernel.ubuntu.com/~kernel-ppa/mainline/v4.4.3-wily/linux-headers-4.4.3-040403-generic_4.4.3-040403.201602251634_amd64.deb \
    kernel.ubuntu.com/~kernel-ppa/mainline/v4.4.3-wily/linux-image-4.4.3-040403-generic_4.4.3-040403.201602251634_amd64.deb

    sudo dpkg -i linux-headers-4.4*.deb linux-image-4.4*.deb

If you have conflicts with nvidia drivers, then install beta-drivers from ppa::

    sudo add-apt-repository ppa:graphics-drivers/ppa

lnvm tool
=========

Add repos and install lnvm::

    sudo add-apt-repository ppa:lightnvm/ppa && sudo apt-get update
    sudo apt-get install lnvm

Load the module::

    sudo modprobe null_blk use_lightnvm=1 gb=4
    dmesg | grep nvm

And check that the output of dmesg has something along the lines of::

    [  286.544447] nvm: registered nullb0 [1/1/256/4096/1/1]
    [  286.544784] nvm: registered nullb1 [1/1/256/4096/1/1]

Then add to the module to autoload

qemu
====

Prerequisites::

    sudo apt-get install libcap-dev libattr1-dev

clone, configure and install qemu-nvme::

    cd ~/Repos
    git clone https://github.com/OpenChannelSSD/qemu-nvme.git
    ./configure --enable-linux-aio --target-list=x86_64-softmmu --enable-kvm --enable-virtfs

Kernel for guest
================

clone::

    cd ~/Repos
    git clone https://github.com/OpenChannelSSD/linux.git

Want to enable virtfs and OpenChannelSSD, so check that the following are in your ```.config```::

    CONFIG_NVM=y
    CONFIG_NVM_DEBUG=y          # Expose the /sys/module/lnvm/parameters/configure_debug interface
    CONFIG_NVM_RRPC=y           # Hybrid target support (required to expose the open-channel SSD as a block device)
    CONFIG_NVM_GENNVM=y         # generic media manager support (required)
    CONFIG_BLK_DEV_NULL_BLK=y   # For null_blk support
    CONFIG_BLK_DEV_NVME=y       # For NVMe support

For mounting::

    CONFIG_NET_9P=y
    CONFIG_NET_9P_VIRTIO=y
    CONFIG_9P_FS=y
    CONFIG_9P_FS_POSIX_ACL=y
    CONFIG_9P_FS_SECURITY=y


fio
===

clone, configure::

    cd ~/Repos
    git clone git@github.com:MatiasBjorling/lightnvm-fio.git
    ./configure

Play around with liblightnvm
============================

git@github.com:OpenChannelSSD/qemu-nvme.git:liblnvm

cherry-pick: cca08be5485691cd6f784748d8340255485a0214 to for virtio fix

git@github.com:OpenChannelSSD/linux.git:liblnvm

Make sure that "Direct Flash support for liblightnvm" is added to config.

Boot the vm and then add these:

git@github.com:OpenChannelSSD/liblightnvm.git:master
git@github.com:MatiasBjorling/lightnvm-fio.git:lightnvm


