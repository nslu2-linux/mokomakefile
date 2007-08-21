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

# OPENMOKO_GENERATION = 2007.1
OPENMOKO_GENERATION = 2007.2

OPENMOKO_SVN_REV = HEAD
BITBAKE_SVN_REV = HEAD
ifeq ("${OPENMOKO_GENERATION}","2007.1")
OPENMOKO_MTN_REV = e2dbb52fe39df7ef786b6068f6178f29508dfded
else
OPENMOKO_MTN_REV = HEAD
endif

MTN := mtn

ifneq ("${OPENMOKO_MTN_REV}","HEAD")
MTN_REV_FLAGS = -r ${OPENMOKO_MTN_REV}
endif

OE_SNAPSHOT_SITE := http://www.openembedded.org/snapshots

# Set it back to these (svn:// protocol) when anon svn is fixed.
# MM_SVN_SITE := svn.projects.openmoko.org
# MM_SVN_PATH := /var/lib/gforge/chroot/svnroot/mokomakefile
MM_SVN_SITE := svn.nslu2-linux.org
ifeq ("${OPENMOKO_GENERATION}","2007.1")
MM_SVN_PATH := svnroot/mokomakefile/branches/OM-2007.1
else
MM_SVN_PATH := svnroot/mokomakefile/trunk
endif

ifeq ("${OPENMOKO_GENERATION}","2007.1")
BB_SVN_PATH := bitbake/branches/bitbake-1.6
else
BB_SVN_PATH := bitbake/branches/bitbake-1.8
endif

.PHONY: all
all: openmoko-devel-image openmoko-devel-tools build-qemu

.PHONY: force-rebuild
force-rebuild:
	perl -ne '/SRCDATE_([^ ]+)/ and print "$$1\n";' \
		openmoko/trunk/oe/conf/distro/include/preferred-openmoko-versions.inc | \
		xargs -i find build/tmp/{stamps,work}/* -name '{}-*' -prune -print | \
		xargs /bin/rm -rf

.PHONY: setup
setup:  check-generation setup-patches \
	setup-bitbake setup-mtn setup-openembedded setup-openmoko \
	setup-config setup-env

.PHONY: update
update: check-generation update-mtn update-patches update-openembedded update-bitbake update-openmoko

.PHONY: check-generation
check-generation:
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	@ echo "   ___                               _           ____   ___   ___ _____ _ "
	@ echo "  /___\_ __   ___ _ __   /\/\   ___ | | _____   |___ \ / _ \ / _ \___  / |"
	@ echo " //  // '_ \ / _ \ '_ \ /    \ / _ \| |/ / _ \    __) | | | | | | | / /| |"
	@ echo "/ \_//| |_) |  __/ | | / /\/\ \ (_) |   < (_) |  / __/| |_| | |_| |/ /_| |"
	@ echo "\___/ | .__/ \___|_| |_\/    \/\___/|_|\_\___/  |_____|\___/ \___//_/(_)_|"
	@ echo "      |_|                                                                 "
	@ echo
else
	@ echo "   ___                               _           ____   ___   ___ _____ ____  "
	@ echo "  /___\_ __   ___ _ __   /\/\   ___ | | _____   |___ \ / _ \ / _ \___  |___ \ "
	@ echo " //  // '_ \ / _ \ '_ \ /    \ / _ \| |/ / _ \    __) | | | | | | | / /  __) |"
	@ echo "/ \_//| |_) |  __/ | | / /\/\ \ (_) |   < (_) |  / __/| |_| | |_| |/ /_ / __/ "
	@ echo "\___/ | .__/ \___|_| |_\/    \/\___/|_|\_\___/  |_____|\___/ \___//_/(_)_____|"
	@ echo "      |_|                                                                     "
	@ echo
endif
	[ ! -e stamps/bitbake ] || \
	( grep -e '${BB_SVN_PATH}' bitbake/.svn/entries > /dev/null ) || \
	( rm -rf bitbake stamps/bitbake patches stamps/patches )
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	[ ! -e stamps/openembedded ] || \
	( grep -e '${OPENMOKO_MTN_REV}' openembedded/_MTN/revision > /dev/null ) || \
	( rm -rf openembedded stamps/openembedded && mv build build-OM-2007.2 )
	[ ! -e build-OM-2007.1 ] || \
	( mv build-OM-2007.1 build )
	[ ! -e setup-env ] || \
	( grep -e '$${OMDIR}/oe' setup-env > /dev/null ) || \
	( rm -f setup-env )
else
	[ ! -e stamps/openembedded ] || \
	[ -z "`grep -e 'e2dbb52fe39df7ef786b6068f6178f29508dfded' openembedded/_MTN/revision`" ] || \
	( rm -rf openembedded stamps/openembedded && mv build build-OM-2007.1 )
	[ ! -e build-OM-2007.2 ] || \
	( mv build-OM-2007.2 build )
	[ ! -e setup-env ] || \
	[ -z "`grep -e '$${OMDIR}/oe' setup-env`" ] || \
	( rm -f setup-env )
	[ ! -e oe ] || \
	( rm -f oe )
endif

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
setup-mtn stamps/OE.mtn: OE.mtn
	[ -e stamps/OE.mtn ] || \
	( ${MTN} --db=OE.mtn db migrate && \
	  ${MTN} --db=OE.mtn pull monotone.openembedded.org org.openembedded.dev )
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
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	[ -e oe ] || \
	( ln -sfn openmoko/trunk/oe . )
endif
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
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	[ -e oe ] || \
	( ln -sfn openmoko/trunk/oe . )
endif
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
	  echo 'BUILD_ARCH = "'`uname -m`'"' >> build/conf/local.conf )
ifneq ("${OPENMOKO_GENERATION}","2007.1")
	rm -f build/conf/site.conf
	( ln -sfn ../../openmoko/trunk/src/host/openembedded/site.conf build/conf/site.conf )
endif

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
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	echo \
	'export BBPATH="$${OMDIR}/build:$${OMDIR}/oe:$${OMDIR}/openembedded"' \
		>> setup-env
else
	echo \
	'export BBPATH="$${OMDIR}/build:$${OMDIR}/openembedded"' \
		>> setup-env
endif
	echo \
	'export PYTHONPATH="$${OMDIR}/bitbake/libbitbake"' \
		>> setup-env
	echo \
	'export PATH="$${OMDIR}/bitbake/bin:$${PATH}"' \
		>> setup-env

.PHONY: update-makefile
update-makefile:
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	( wget -O Makefile.new http://svn.nslu2-linux.org/svnroot/mokomakefile/branches/OM-2007.1/Makefile && \
	  mv Makefile.new Makefile )
else
	( wget -O Makefile.new http://svn.nslu2-linux.org/svnroot/mokomakefile/trunk/Makefile && \
	  mv Makefile.new Makefile )
endif

.PHONY: check-makefile
check-makefile:
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	( wget -O - http://svn.nslu2-linux.org/svnroot/mokomakefile/branches/OM-2007.1/Makefile | \
	  diff -u Makefile - )
else
	( wget -O - http://svn.nslu2-linux.org/svnroot/mokomakefile/trunk/Makefile | \
	  diff -u Makefile - )
endif

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
		${MTN} --db=OE.mtn pull monotone.openembedded.org org.openembedded.dev ; \
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
	  bitbake -c fetch openmoko-devel-image )

.PHONY: remove-work
remove-work: stamps/openmoko stamps/bitbake \
		stamps/openembedded stamps/patches \
		build/conf/local.conf setup-env
	( cd build && . ../setup-env && \
	  bitbake -c rm_work openmoko-devel-image )

.PHONY: openmoko-devel-image
openmoko-devel-image stamps/openmoko-devel-image: \
		stamps/openmoko stamps/bitbake \
		stamps/openembedded stamps/patches \
		build/conf/local.conf setup-env
	( cd build && . ../setup-env && \
	  bitbake openmoko-devel-image )
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
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	( cd build/qemu && openmoko/flash.sh ../tmp/deploy/images )
else
	( cd build/qemu && openmoko/flash.sh ../tmp/deploy/glibc/images/fic-gta01 )
endif

build/qemu/openmoko/openmoko-sd.image:
	( cd build/qemu && /sbin/mkdosfs -C -F 32 -v openmoko/openmoko-sd.image 500000 )

.PHONY: run-qemu
run-qemu: stamps/qemu build/qemu/openmoko/openmoko-sd.image
	( cd build/qemu && arm-softmmu/qemu-system-arm \
		-M neo -m 130 -usb -show-cursor \
		-usbdevice keyboard \
		-mtdblock openmoko/openmoko-flash.image \
		-sd openmoko/openmoko-sd.image \
		-kernel openmoko/openmoko-kernel.bin )

.PHONY: run-qemu-snapshot
run-qemu-snapshot: stamps/qemu build/qemu/openmoko/openmoko-sd.image
	( cd build/qemu && arm-softmmu/qemu-system-arm \
		-M neo -m 130 -usb -show-cursor -snapshot \
		-usbdevice keyboard \
		-mtdblock openmoko/openmoko-flash.image \
		-sd openmoko/openmoko-sd.image \
		-kernel openmoko/openmoko-kernel.bin )

.PHONY: run-qemu-vnc
run-qemu-vnc: stamps/qemu build/qemu/openmoko/openmoko-sd.image
	( cd build/qemu && arm-softmmu/qemu-system-arm \
		-M neo -m 130 -usb -show-cursor \
		-vnc localhost:1 -monitor stdio \
		-mtdblock openmoko/openmoko-flash.image \
		-sd openmoko/openmoko-sd.image \
		-kernel openmoko/openmoko-kernel.bin )

.PHONY: flash-neo-official
flash-neo-official: stamps/openmoko-devel-tools stamps/images
	( cd build && ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a kernel -D `ls -t ../images/openmoko/uImage-*.bin | head -1` )
	( cd build && ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a rootfs -D `ls -t ../images/openmoko/*.jffs2 | head -1` )

.PHONY: flash-neo-local
flash-neo-local: stamps/openmoko-devel-tools stamps/openmoko-devel-image
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	( cd build && ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a kernel -D `ls -t tmp/deploy/images/uImage-*.bin | head -1` )
	( cd build && ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a rootfs -D `ls -t tmp/deploy/images/*.jffs2 | head -1` )
else
	( cd build && ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a kernel -D `ls -t tmp/deploy/glibc/images/fic-gta01/uImage-*.bin | head -1` )
	( cd build && ./tmp/staging/`uname -m`-`uname -s | tr '[A-Z]' '[a-z]'`/bin/dfu-util \
		--device 0x1457:0x5119 -a rootfs -D `ls -t tmp/deploy/glibc/images/fic-gta01/*.jffs2 | head -1` )
endif

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
	( cd openembedded && ${MTN} push monotone.openembedded.org org.openembedded.dev )

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
ifeq ("${OPENMOKO_GENERATION}","2007.1")
	mcopy -i build/qemu/openmoko/openmoko-sd.image -v build/tmp/deploy/ipk/*/$*_*.ipk ::
else
	mcopy -i build/qemu/openmoko/openmoko-sd.image -v build/tmp/deploy/glibc/ipk/*/$*_*.ipk ::
endif

.PHONY: clobber
clobber: clobber-patches clobber-bitbake clobber-openmoko clobber-openembedded clobber-qemu

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
clobber-openembedded:
	rm -rf build/tmp openembedded stamps/openembedded stamps/openmoko-devel-image

.PHONY: clobber-qemu
clobber-qemu:
	rm -rf build/qemu stamps/qemu
