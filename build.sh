#!/bin/bash
#
# abyss oneplus2 build script
#
clear

# Resources
THREAD="-j7"
KERNEL="Image.gz-dtb"
DEFCONFIG="reactive_defconfig"
DEVICE="oneplus2"

# Kernel Details
VARIANT=$(date +"%Y%m%d")
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=${HOME}/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-

# Paths
KERNEL_DIR="${HOME}/kernel/oneplus2"
ANYKERNEL_DIR="$KERNEL_DIR/anykernel2"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE_NIGHTLY="${HOME}/kernel/out/$DEVICE"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"
KERNEL_VER=$( grep -r "EXTRAVERSION = -Reactive-" ${KERNEL_DIR}/Makefile | sed 's/EXTRAVERSION = -Reactive-//' )

# Functions
function clean_all {
		echo
		find . -name "*~" -type f -delete
		rm -rf $ANYKERNEL_DIR/$KERNEL
		rm -rf $MODULES_DIR/*
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
}

function make_zip {
		cp -vr $ZIMAGE_DIR/$KERNEL $ANYKERNEL_DIR/$KERNEL
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		cd $ANYKERNEL_DIR
		zip -r9 reactive-kernel-$DEVICE-$KERNEL_VER.zip *
		mv reactive-kernel-$DEVICE-$KERNEL_VER.zip $ZIP_MOVE_NIGHTLY
		cd $KERNEL_DIR
}

cat << "EOF"

             7=7777777M
           7=7777777777$
          7=77777777777O$M
         7=77777777777ZZ$$
         7=777777777777$$$M
         7=7777MM777MM$$$$M
          7=Z7M777M7D77$$$        M8
  ?$?      M77N0=M7000$$M         $$Z
 MO    M    $$7777$$$$$$$        $Z  8Z
  OO       $OOMM$ZM$ZM$ZZ$N    M$Z
   OO$$$$$OO  M$ZMO$$MM$ZOZZ$$$ZM
         MMZ$$ZM MM$Z M$ZOO
M$ZZZDMMMMM88M   O$$M ZZM OO
M     MOOM      O$$M  $Z  MOM
     OM M$$$M   $Z    $   MZZ
      M     ZZ$ZMD   MZM$ZM8 MM
                  O   $O  O

EOF

echo "You are building abyss $KERNEL_VER for $DEVICE";
echo

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		DATE_START=$(date +"%s")
		make_kernel
		if [ -f $ZIMAGE_DIR/$KERNEL ];
		then
			make_zip
		else
			echo
			echo "Kernel build failed."
			echo
		fi
		break
		;;
	n|N )
		DATE_START=$(date +"%s")
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
