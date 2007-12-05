# "MokoMakefile" - a Makefile for setting up OpenMoko builds
#
# Copyright (c) 2007  Rod Whitby <rod@whitby.id.au>
# All rights reserved.
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA  02110-1301, USA

OPENMOKO_GENERATION = 2007.2

OPENMOKO_SVN_REV = HEAD
BITBAKE_SVN_REV = HEAD
OPENMOKO_MTN_REV = HEAD

MTN := mtn
MKDOSFS := /sbin/mkdosfs

ifneq ("${OPENMOKO_MTN_REV}","HEAD")
MTN_REV_FLAGS = -r ${OPENMOKO_MTN_REV}
endif

OE_SNAPSHOT_SITE := http://downloads.openmoko.org/OE/snapshots

OM_MONOTONE_SITE := monotone.openmoko.org

# Set it back to these (svn:// protocol) when anon svn is fixed.
# MM_SVN_SITE := svn.projects.openmoko.org
# MM_SVN_PATH := /var/lib/gforge/chroot/svnroot/mokomakefile
MM_SVN_SITE := svn.nslu2-linux.org
MM_SVN_PATH := svnroot/mokomakefile/trunk

BB_SVN_PATH := bitbake/tags/bitbake-1.8.8

.PHONY: all
all: openmoko-devel-image openmoko-devel-tools build-qemu openmoko-feed

.PHONY: image
image: openmoko-devel-image

.PHONY: tools
tools: openmoko-devel-tools

.PHONY: feed
feed: openmoko-feed

.PHONY: force-rebuild
force-rebuild:
	find build/tmp/work -name "*+svn*" -type d -print | \
		xargs /bin/rm -rf
	find build/tmp/stamps -name "*+svn*" -type f -print | \
		xargs /bin/rm -f

.PHONY: setup
setup:  check-generation setup-patches \
	setup-bitbake setup-mtn setup-openembedded setup-openmoko \
	setup-config setup-env

.PHONY: update
update: check-generation update-mtn update-patches update-openembedded update-bitbake update-openmoko

.PHONY: update-stable
update-stable:
	${MAKE} OM_MONOTONE_SITE=monotone.openmoko.org update

.PHONY: update-bleeding-edge
update-bleeding-edge:
	${MAKE} OM_MONOTONE_SITE=monotone.openembedded.org update

.PHONY: check-generation
check-generation:
	@ echo "   ___                               _           ____   ___   ___ _____ ____  "
	@ echo "  /___\_ __   ___ _ __   /\/\   ___ | | _____   |___ \ / _ \ / _ \___  |___ \ "
	@ echo " //  // '_ \ / _ \ '_ \ /    \ / _ \| |/ / _ \    __) | | | | | | | / /  __) |"
	@ echo "/ \_//| |_) |  __/ | | / /\/\ \ (_) |   < (_) |  / __/| |_| | |_| |/ /_ / __/ "
	@ echo "\___/ | .__/ \___|_| |_\/    \/\___/|_|\_\___/  |_____|\___/ \___//_/(_)_____|"
	@ echo "      |_|                                                                     "
	@ echo
	[ ! -e stamps/bitbake ] || \
	( grep -e '${BB_SVN_PATH}' bitbake/.svn/entries > /dev/null ) || \
	( rm -rf bitbake stamps/bitbake patches stamps/patches )

.PHONY: setup-bitbake
setup-bitbake stamps/bitbake: stamps/patches
	[ -e stamps/bitbake ] || \
	( svn co -r ${BITBAKE_SVN_REV} svn://svn.berlios.de/${BB_SVN_PATH} bitbake )
	rm -f bitbake/patches
	[ ! -e patches/bitbake-${BITBAKE_SVN_REV}/series ] || \
	( ln -sfn ../patches/bitbake-${BITBAKE_SVN_REV} bitbake/patches )
	[ ! -e bitbake/patches/series ] || \
	( cd bitbake && quilt push -a )
	[ -d stamps ] || mkdir stamps
	touch stamps/bitbake

OE.mtn:
	if [ -z "`${MTN} --version | awk '{ print $$2; }'`" ] ; then \
	  echo 'Cannot determine version for monotone using "${MTN} --version"' ; \
	  false ; \
	fi
	[ -e OE.mtn ] || \
	( ( version=`${MTN} --version | awk '{ print $$2; }'` ; \
	    wget -c -O OE.mtn.bz2 \
		${OE_SNAPSHOT_SITE}/OE-this-is-for-mtn-$$version.mtn.bz2 || \
	    wget -c -O OE.mtn.bz2 \
		${OE_SNAPSHOT_SITE}/OE.mtn.bz2 ) && \
	  bunzip2 -c OE.mtn.bz2 > OE.mtn.partial && \
	  mv OE.mtn.partial OE.mtn )

.PHONY: setup-mtn
setup-mtn stamps/OE.mtn:
	[ -e OE.mtn ] || \
	${MAKE} OE.mtn
	[ -e stamps/OE.mtn ] || \
	( ${MTN} --db=OE.mtn db migrate && \
	  ${MTN} --db=OE.mtn pull ${OM_MONOTONE_SITE} org.openembedded.dev )
	[ -d stamps ] || mkdir stamps
	touch stamps/OE.mtn

.PHONY: setup-openembedded
setup-openembedded stamps/openembedded: stamps/OE.mtn stamps/patches
	[ -e stamps/openembedded ] || \
	( ${MTN} --db=OE.mtn checkout --branch=org.openembedded.dev \
		${MTN_REV_FLAGS} openembedded ) || \
	( ${MTN} --db=OE.mtn checkout --branch=org.openembedded.dev \
		-r `${MTN} --db=OE.mtn automate heads org.openembedded.dev | head -n1` openembedded )
	rm -f openembedded/patches
	[ ! -e patches/openembedded-${OPENMOKO_MTN_REV}/series ] || \
	( ln -sfn ../patches/openembedded-${OPENMOKO_MTN_REV} openembedded/patches )
	[ ! -e openembedded/patches/series ] || \
	( cd openembedded && quilt push -a )
	[ -d stamps ] || mkdir stamps
	touch stamps/openembedded

.PHONY: setup-openmoko-developer
setup-openmoko-developer: stamps/patches
	[ ! -e openmoko ] || ( mv openmoko openmoko-user )
	( svn co -r ${OPENMOKO_SVN_REV} https://svn.openmoko.org/ openmoko )
	rm -f openmoko/patches
	[ ! -e patches/openmoko-${OPENMOKO_SVN_REV}/series ] || \
	( ln -sfn ../patches/openmoko-${OPENMOKO_SVN_REV} openmoko/patches )
	[ ! -e openmoko/patches/series ] || \
	( cd openmoko && quilt push -a )
	[ -d stamps ] || mkdir stamps
	touch stamps/openmoko

.PHONY: setup-openmoko
setup-openmoko stamps/openmoko: stamps/patches
	[ -e stamps/openmoko ] || [ -e openmoko/.svn/entries ] || \
	( svn co -r ${OPENMOKO_SVN_REV} http://svn.openmoko.org/ openmoko )
	rm -f openmoko/patches
	[ ! -e patches/openmoko-${OPENMOKO_SVN_REV}/series ] || \
	( ln -sfn ../patches/openmoko-${OPENMOKO_SVN_REV} openmoko/patches )
	[ ! -e openmoko/patches/series ] || \
	( cd openmoko && quilt push -a )
	[ -d stamps ] || mkdir stamps
	touch stamps/openmoko

.PHONY: setup-patches
setup-patches stamps/patches:
	[ -e stamps/patches ] || \
	( svn co http://${MM_SVN_SITE}/${MM_SVN_PATH}/patches patches )
	[ -d stamps ] || mkdir stamps
	touch stamps/patches

.PHONY: setup-config
setup-config build/conf/local.conf:
	mkdir -p build/conf
	[ -e build/conf/local.conf ] || \
	( echo 'MACHINE = "fic-gta01"' > build/conf/local.conf ; \
	  echo 'DISTRO = "openmoko"' >> build/conf/local.conf ; \
	  echo 'BUILD_ARCH = "'`uname -m`'"' >> build/conf/local.conf ; \
	  echo 'INHERIT += "rm_work"' >> build/conf/local.conf )
	rm -f build/conf/site.conf
	( ln -sfn ../../openmoko/trunk/src/host/openembedded/site.conf build/conf/site.conf )

.PHONY: setup-machine-neo
setup-machine-neo: setup-machine-fic-gta01

.PHONY: setup-machine-pc
setup-machine-pc: setup-machine-x86

.PHONY: setup-machine-%
setup-machine-%: setup-config
	sed -i -e 's/^MACHINE[[:space:]]*=[[:space:]]*\".*\"/MACHINE = \"$*\"/' \
		build/conf/local.conf

setup-env:
	[ -e setup-env ] || \
	echo 'export OMDIR="'`pwd`'"' > setup-env
	echo \
	'export BBPATH="$${OMDIR}/build:$${OMDIR}/openembedded"' \
		>> setup-env
	echo \
	'export PYTHONPATH="$${OMDIR}/bitbake/libbitbake"' \
		>> setup-env
	echo \
	'export PATH="$${OMDIR}/bitbake/bin:$${PATH}"' \
		>> setup-env

.PHONY: update-makefile
update-makefile:
	( wget -O Makefile.new http://svn.nslu2-linux.org/svnroot/mokomakefile/trunk/Makefile && \
	  mv Makefile.new Makefile )

.PHONY: check-makefile
check-makefile:
	( wget -O - http://svn.nslu2-linux.org/svnroot/mokomakefile/trunk/Makefile | \
	  diff -u Makefile - )

.PHONY: update-bitbake
update-bitbake: stamps/bitbake
	[ ! -e bitbake/patches ] || \
	( cd bitbake && quilt pop -a -f ) || true
	[ ! -e bitbake/patches ] || \
	( cd bitbake && svn revert -R . )
	( cd bitbake && svn update -r ${BITBAKE_SVN_REV} )
	rm -f bitbake/patches
	[ ! -e patches/bitbake-${BITBAKE_SVN_REV}/series ] || \
	( ln -sfn ../patches/bitbake-${BITBAKE_SVN_REV} bitbake/patches )
	[ ! -e bitbake/patches/series ] || \
	( cd bitbake && quilt push -a )

.PHONY: update-mtn
update-mtn: stamps/OE.mtn
	if [ "${OPENMOKO_MTN_REV}" != "`(cd openembedded && ${MTN} automate get_base_revision_id)`" ] ; then \
		${MTN} --db=OE.mtn pull ${OM_MONOTONE_SITE} org.openembedded.dev ; \
	fi

.PHONY: update-openembedded
update-openembedded: update-mtn stamps/openembedded
	[ ! -e openembedded/patches ] || \
	( cd openembedded && quilt pop -a -f ) || true
	[ ! -e openembedded/patches ] || \
	( cd openembedded && ${MTN} revert . )
	( cd openembedded && ${MTN} update ${MTN_REV_FLAGS} ) || \
	( cd openembedded && ${MTN} update \
		-r `${MTN} automate heads | head -n1` )
	rm -f openembedded/patches
	[ ! -e patches/openembedded-${OPENMOKO_MTN_REV}/series ] || \
	( ln -sfn ../patches/openembedded-${OPENMOKO_MTN_REV} openembedded/patches )
	[ ! -e openembedded/patches/series ] || \
	( cd openembedded && quilt push -a )

.PHONY: update-patches
update-patches: stamps/patches
	( cd patches && svn update )

.PHONY: update-openmoko
update-openmoko: stamps/openmoko
	[ ! -e openmoko/patches ] || \
	( cd openmoko && quilt pop -a -f ) || true
	[ ! -e openmoko/patches ] || \
	( cd openmoko && svn revert -R . )
	( cd openmoko && svn update -r ${OPENMOKO_SVN_REV} )
	rm -f openmoko/patches
	[ ! -e patches/openmoko-${OPENMOKO_SVN_REV}/series ] || \
	( ln -sfn ../patches/openmoko-${OPENMOKO_SVN_REV} openmoko/patches )
	[ ! -e openmoko/patches/series ] || \
	( cd openmoko && quilt push -a )

.PHONY: prefetch-sources
prefetch-sources: stamps/openmoko stamps/bitbake \
		stamps/openembedded stamps/patches \
		build/conf/local.conf setup-env
	( cd build && . ../setup-env && \
	  bitbake -c fetch openmoko-devel-image uboot-openmoko )

.PHONY: remove-work
remove-work: stamps/openmoko stamps/bitbake \
		stamps/openembedded stamps/patches \
		build/conf/local.conf setup-env
	( cd build && . ../setup-env && \
	  bitbake -c rm_work openmoko-devel-image uboot-openmoko )

.PHONY: openmoko-devel-image
openmoko-devel-image stamps/openmoko-devel-image: \
		stamps/openmoko stamps/bitbake \
		stamps/openembedded stamps/patches \
		build/conf/local.conf setup-env
	( cd build && . ../setup-env && \
	  bitbake openmoko-devel-image uboot-openmoko )
	[ -d stamps ] || mkdir stamps
	touch stamps/openmoko-devel-image

.PHONY: openmoko-devel-tools
openmoko-devel-tools stamps/openmoko-devel-tools: \
		stamps/openmoko stamps/bitbake \
		stamps/openembedded stamps/patches \
		build/conf/local.conf setup-env
	( cd build && . ../setup-env && \
	  bitbake dfu-util-native openocd-native )
	[ -d stamps ] || mkdir stamps
	touch stamps/openmoko-devel-tools

.PHONY: openmoko-feed
openmoko-feed stamps/openmoko-feed: \
		stamps/openmoko stamps/bitbake \
		stamps/openembedded stamps/patches \
		build/conf/local.conf setup-env
	( cd build && . ../setup-env && \
	  bitbake openmoko-feed )
	[ -d stamps ] || mkdir stamps
	touch stamps/openmoko-feed

.PHONY: qemu
qemu: setup-qemu build-qemu download-images flash-qemu-official run-qemu

.PHONY: qemu-local
qemu-local: setup-qemu build-qemu openmoko-devel-image flash-qemu-local run-qemu

.PHONY: setup-qemu
setup-qemu stamps/qemu: setup-env \
		stamps/openmoko stamps/patches
	[ -e build/qemu ] || \
	( mkdir -p build/qemu )
	[ -e build/qemu/Makefile ] || \
	( . ./setup-env && cd build/qemu && \
	  $${OMDIR}/openmoko/trunk/src/host/qemu-neo1973/configure \
		--target-list=arm-softmmu )
	[ -e build/qemu/openmoko ] || \
	( . ./setup-env && cd build/qemu && mkdir openmoko && \
	  for f in $${OMDIR}/openmoko/trunk/src/host/qemu-neo1973/openmoko/* ; do \
	    ln -s $$f openmoko/`basename $$f` ; \
	  done )
	ln -sf `pwd`/openmoko/trunk/src/host/qemu-neo1973/openmoko/env build/qemu/openmoko/env
	[ -d stamps ] || mkdir stamps
	touch stamps/qemu

.PHONY: build-qemu
build-qemu build/qemu/arm-softmmu/qemu-system-arm: stamps/qemu
	( cd build/qemu && ${MAKE} )

.PHONY: download-images
download-images stamps/images: stamps/openmoko
	[ -e images/openmoko ] || mkdir -p images/openmoko
	ln -sf `pwd`/openmoko/trunk/src/host/qemu-neo1973/openmoko/env images/openmoko/env
	( cd images && ../openmoko/trunk/src/host/qemu-neo1973/openmoko/download.sh )
	rm -f images/openmoko/env
	[ -d stamps ] || mkdir stamps
	touch stamps/images

.PHONY: flash-qemu-official
flash-qemu-official: stamps/qemu stamps/images
	( cd build/qemu && openmoko/flash.sh ../../images/openmoko )

.PHONY: flash-qemu-local
flash-qemu-local: stamps/qemu stamps/openmoko-devel-image
	( cd build/qemu && openmoko/flash.sh ../tmp/deploy/glibc/images/neo1973 )

build/qemu/openmoko/openmoko-sd.image:
	( cd build/qemu && ${MKDOSFS} -C -F 32 -v openmoko/openmoko-sd.image 500000 )

.PHONY: run-qemu
run-qemu: stamps/qemu build/qemu/openmoko/openmoko-sd.image
	( cd build/qemu && arm-softmmu/qemu-system-arm \
		-M gta01 -m 130 -usb -show-cursor \
		-usbdevice keyboard \
		-mtdblock openmoko/openmoko-flash.image \
		-sd openmoko/openmoko-sd.image \
		-kernel openmoko/openmoko-kernel.bin )

.PHONY: run-qemu-snapshot
run-qemu-snapshot: stamps/qemu build/qemu/openmoko/openmoko-sd.image
	( cd build/qemu && arm-softmmu/qemu-system-arm \
		-M gta01 -m 130 -usb -show-cursor -snapshot \
		-usbdevice keyboard \
		-mtdblock openmoko/openmoko-flash.image \
		-sd openmoko/openmoko-sd.image \
		-kernel openmoko/openmoko-kernel.bin )

.PHONY: run-qemu-vnc
run-qemu-vnc: stamps/qemu build/qemu/openmoko/openmoko-sd.image
	( cd build/qemu && arm-softmmu/qemu-system-arm \
		-M gta01 -m 130 -usb -show-cursor \
		-vnc localhost:1 -monitor stdio \
		-mtdblock openmoko/openmoko-flash.image \
		-sd openmoko/openmoko-sd.image \
		-kernel openmoko/openmoko-kernel.bin )

.PHONY: flash-neo-official
flash-neo-official: flash-neo-kernel-official flash-neo-rootfs-official

.PHONY: flash-neo-kernel-official
flash-neo-kernel-official: stamps/openmoko-devel-tools stamps/images
	( cd build && \
		sudo ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a kernel -D `ls -t ../images/openmoko/uImage-*.bin | head -1` )

.PHONY: flash-neo-rootfs-official
flash-neo-rootfs-official: stamps/openmoko-devel-tools stamps/images
	( cd build && \
		sudo ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a rootfs -D `ls -t ../images/openmoko/*.jffs2 | head -1` )

.PHONY: flash-neo-local
flash-neo-local: flash-neo-kernel-local flash-neo-rootfs-local

.PHONY: flash-neo-kernel-local
flash-neo-kernel-local: stamps/openmoko-devel-tools stamps/openmoko-devel-image
	( cd build && \
		sudo ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a kernel -D `ls -t tmp/deploy/glibc/images/neo1973/uImage-*.bin | head -1` )

.PHONY: flash-neo-rootfs-local
flash-neo-rootfs-local: stamps/openmoko-devel-tools stamps/openmoko-devel-image
	( cd build && \
		sudo ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a rootfs -D `ls -t tmp/deploy/glibc/images/neo1973/*.jffs2 | head -1` )

.PHONY: push-openembedded
push-openembedded: update-mtn openembedded/_MTN/revision
	if [ `${MTN} --db=OE.mtn automate heads org.openembedded.dev | wc -l` \
		!= "1" ] ; then \
	  ${MTN} --db=OE.mtn merge -b org.openembedded.dev ; \
	fi
	( cd openembedded && ${MTN} update )
	if [ `${MTN} --db=OE.mtn automate heads org.openembedded.dev | wc -l` \
		!= "1" ] ; then \
	  ${MTN} --db=OE.mtn merge -b org.openembedded.dev ; \
	fi
	( cd openembedded && ${MTN} push ${OM_MONOTONE_SITE} org.openembedded.dev )

.PHONY: build-package-%
build-package-%:
	( . ./setup-env && cd build && bitbake -c build $* )

.PHONY: rebuild-package-%
rebuild-package-%:
	( . ./setup-env && cd build && bitbake -c rebuild $* )

.PHONY: clean-package-%
clean-package-%:
	( . ./setup-env && cd build && bitbake -c clean $* )

.PHONY: qemu-copy-package-%
qemu-copy-package-%: build/qemu/openmoko/openmoko-sd.image
	mcopy -i build/qemu/openmoko/openmoko-sd.image -v build/tmp/deploy/glibc/ipk/*/$*_*.ipk ::

.PHONY: clean
clean: clean-openembedded clean-qemu

.PHONY: clean-openembedded
clean-openembedded:
	rm -rf build/tmp \
		stamps/openmoko-devel-image \
		stamps/openmoko-devel-tools \
		stamps/openmoko-feed

.PHONY: clean-qemu
clean-qemu:
	rm -rf build/qemu stamps/qemu

.PHONY: clobber
clobber: clobber-bitbake clobber-openmoko clobber-openembedded clobber-qemu

.PHONY: clobber-patches
clobber-patches:
	rm -rf patches stamps/patches

.PHONY: clobber-bitbake
clobber-bitbake:
	rm -rf bitbake stamps/bitbake

.PHONY: clobber-openmoko
clobber-openmoko:
	rm -rf openmoko stamps/openmoko

.PHONY: clobber-openembedded
clobber-openembedded: clean-openembedded
	rm -rf openembedded stamps/openembedded

.PHONY: clobber-qemu
clobber-qemu: clean-qemu
