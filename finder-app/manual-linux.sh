#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
SCRIPTDIR=$PWD
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

echo "-----------------"
echo "SCRIPTDIR = ${SCRIPTDIR}"
echo "-----------------"


if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # Apply yyloc patch if ubuntu ver == 22.04
    if [ $(lsb_release -s -r) = "22.04" ]; then
	echo "Applying patch for 22.04"
	wget https://github.com/torvalds/linux/commit/e33a814e772cdc36436c8c188d8c42d019fda639.patch
	git apply ./e33a814e772cdc36436c8c188d8c42d019fda639.patch
    fi

    # [-] TODO: Add your kernel build steps here

    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make -j8 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# [-]TODO: Create necessary base directories

mkdir rootfs
cd rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    #[-] TODO:  Configure busybox

    echo "Configuring BusyBox"
    make distclean
    make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
echo "Installing Busybox..."
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install



# TODO: Add library dependencies to rootfs
echo "Adding BusyBox deps"
cd $(${CROSS_COMPILE}gcc -print-sysroot)
cp -r lib/* $OUTDIR/rootfs/lib
cp -r lib64/* $OUTDIR/rootfs/lib64

# TODO: Make device nodes
sudo mknod -m 666 $OUTDIR/rootfs/dev/null c 1 3
sudo mknod -m 600 $OUTDIR/rootfs/dev/console c 5 1


# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cd $SCRIPTDIR
cp -r conf/ finder.sh finder-test.sh autorun-qemu.sh writer.sh $OUTDIR/rootfs/home 
cd ..
cp -r conf/ $OUTDIR/rootfs/
cd $SCRIPTDIR

# TODO: Clean and build the writer utility
make clean
make writer

# TODO: Chown the root directory
cd $OUTDIR/rootfs
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
find . | cpio -H newc -ov --owner root:root > $OUTDIR/initramfs.cpio
if [ $? -ne 0 ]; then
    echo "cpio is fucked"
fi
gzip -f $OUTDIR/initramfs.cpio

echo "Everything nicely done"
