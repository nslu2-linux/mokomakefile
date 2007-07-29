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

# We're totally unfrozen now
OPENMOKO_SVN_REV = HEAD
BITBAKE_SVN_REV = HEAD
OPENMOKO_MTN_REV = e2dbb52fe39df7ef786b6068f6178f29508dfded

MTN_VERSION := $(shell mtn --version | awk '{ print $$2; }')

ifndef MTN_VERSION
$(error Cannot determine version for monotone using "mtn --version")
endif

ifdef OPENMOKO_MTN_REV
MTN_REV_FLAGS = -r ${OPENMOKO_MTN_REV}
endif

OE_SNAPSHOT_SITE := http://www.openembedded.org/snapshots
OE_SNAPSHOT_NAME := OE-this-is-for-mtn-${MTN_VERSION}.mtn.bz2

# Set it back to these (svn:// protocol) when anon svn is fixed.
# MM_SVN_SITE := svn.projects.openmoko.org
# MM_SVN_PATH := /var/lib/gforge/chroot/svnroot/mokomakefile
MM_SVN_SITE := svn.nslu2-linux.org
MM_SVN_PATH := /svnroot/mokomakefile

.PHONY: all
all: openmoko-devel-image openmoko-devel-tools build-qemu

.PHONY: force-rebuild
force-rebuild:
	perl -ne '/SRCDATE_([^ ]+)/ and print "$$1\n";' \
		openmoko/trunk/oe/conf/distro/include/preferred-openmoko-versions.inc | \
		xargs -i find build/tmp/{stamps,work}/* -name '{}-*' -prune -print | \
		xargs /bin/rm -rf

.PHONY: setup
setup:  setup-bitbake setup-mtn setup-openembedded setup-openmoko \
	setup-patches setup-config setup-env

.PHONY: update
update: update-mtn update-patches update-openembedded update-bitbake update-openmoko

.PHONY: setup-bitbake
setup-bitbake stamps/bitbake:
	[ -e stamps/bitbake ] || \
	( svn co -r ${BITBAKE_SVN_REV} svn://svn.berlios.de/bitbake/branches/bitbake-1.6 bitbake )
	[ -d stamps ] || mkdir stamps
	touch stamps/bitbake

OE.mtn:
	[ -e OE.mtn ] || \
	( ( wget -c -O OE.mtn.bz2 ${OE_SNAPSHOT_SITE}/${OE_SNAPSHOT_NAME} || \
	    wget -c -O OE.mtn.bz2 ${OE_SNAPSHOT_SITE}/OE.mtn.bz2 ) && \
	  bunzip2 -c OE.mtn.bz2 > OE.mtn.partial && \
	  mv OE.mtn.partial OE.mtn )

.PHONY: setup-mtn
setup-mtn stamps/OE.mtn: OE.mtn
	[ -e stamps/OE.mtn ] || \
	( mtn --db=OE.mtn db migrate && \
	  mtn --db=OE.mtn pull monotone.openembedded.org org.openembedded.dev )
	[ -d stamps ] || mkdir stamps
	touch stamps/OE.mtn

.PHONY: setup-openembedded
setup-openembedded stamps/openembedded: stamps/OE.mtn
	[ -e stamps/openembedded ] || \
	( mtn --db=OE.mtn checkout --branch=org.openembedded.dev \
		${MTN_REV_FLAGS} openembedded ) || \
	( mtn --db=OE.mtn checkout --branch=org.openembedded.dev \
		-r `mtn --db=OE.mtn automate heads org.openembedded.dev | head -n1` openembedded )
	[ -d stamps ] || mkdir stamps
	touch stamps/openembedded

.PHONY: setup-openmoko-developer
setup-openmoko-developer:
	[ ! -e openmoko ] || ( mv openmoko openmoko-user )
	( svn co -r ${OPENMOKO_SVN_REV} https://svn.openmoko.org/ openmoko )
	[ -e oe ] || \
	( ln -sfn openmoko/trunk/oe . )
	[ -d stamps ] || mkdir stamps
	touch stamps/openmoko

.PHONY: setup-openmoko
setup-openmoko stamps/openmoko:
	[ -e stamps/openmoko ] || \
	( svn co -r ${OPENMOKO_SVN_REV} http://svn.openmoko.org/ openmoko )
	[ -e oe ] || \
	( ln -sfn openmoko/trunk/oe . )
	[ -d stamps ] || mkdir stamps
	touch stamps/openmoko

.PHONY: setup-patches
setup-patches stamps/patches: stamps/bitbake stamps/openembedded stamps/openmoko
	[ -e stamps/patches ] || \
	( svn co http://${MM_SVN_SITE}/${MM_SVN_PATH}/trunk/patches patches )
	[ -e bitbake/patches ] && \
	( cd bitbake && quilt pop -a -f ) || true
	( cd bitbake && svn revert -R . )
	[ -e openmoko/patches ] && \
	( cd openmoko && quilt pop -a -f ) || true
	( cd openmoko && svn revert -R . )
	[ -e openembedded/patches ] && \
	( cd openembedded && quilt pop -a -f ) || true
	( cd openembedded && mtn revert . )
	[ ! -e patches/bitbake-${BITBAKE_SVN_REV} ] || \
	( cd bitbake && rm -f patches && \
	  ln -sfn ../patches/bitbake-${BITBAKE_SVN_REV} patches )
	[ ! -e patches/openmoko-${OPENMOKO_SVN_REV} ] || \
	( cd openmoko && rm -f patches && \
	  ln -sfn ../patches/openmoko-${OPENMOKO_SVN_REV} patches )
	[ ! -e patches/openembedded-${OPENMOKO_MTN_REV} ] || \
	( cd openembedded && rm -f patches && \
	  ln -sfn ../patches/openembedded-${OPENMOKO_MTN_REV} patches )
	[ ! -e openmoko/patches/series ] || \
	( cd openmoko && quilt push -a )
	[ ! -e bitbake/patches/series ] || \
	( cd bitbake && quilt push -a )
	[ ! -e openembedded/patches/series ] || \
	( cd openembedded && quilt push -a )
	[ -d stamps ] || mkdir stamps
	touch stamps/patches

.PHONY: setup-config
setup-config build/conf/local.conf:
	mkdir -p build/conf
	[ -e build/conf/local.conf ] || \
	( echo 'MACHINE = "fic-gta01"' > build/conf/local.conf ; \
	  echo 'DISTRO = "openmoko"' >> build/conf/local.conf ; \
	  echo 'BUILD_ARCH = "'`uname -m`'"' >> build/conf/local.conf )

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
	( echo 'export OMDIR="'`pwd`'"' > setup-env && \
	  echo \
	'export BBPATH="$${OMDIR}/build:$${OMDIR}/oe:$${OMDIR}/openembedded"' \
		>> setup-env && \
	  echo \
	'export PYTHONPATH="$${OMDIR}/bitbake/libbitbake"' \
		>> setup-env && \
	  echo \
	'export PATH="$${OMDIR}/bitbake/bin:$${PATH}"' \
		>> setup-env )

.PHONY: update-makefile
update-makefile:
	( wget -O Makefile.new http://www.rwhitby.net/files/openmoko/Makefile && \
	  mv Makefile.new Makefile )

.PHONY: check-makefile
check-makefile:
	( wget -q -O - http://www.rwhitby.net/files/openmoko/Makefile | \
	  diff -u Makefile - )

.PHONY: update-bitbake
update-bitbake: stamps/bitbake
	( cd bitbake && quilt pop -a -f ) || true
	( cd bitbake && svn revert -R . )
	( cd bitbake && svn update -r ${BITBAKE_SVN_REV} )
	[ ! -e patches/bitbake-${BITBAKE_SVN_REV} ] || \
	( cd bitbake && rm -f patches && \
	  ln -sfn ../patches/bitbake-${BITBAKE_SVN_REV} patches )
	[ ! -e bitbake/patches/series ] || \
	( cd bitbake && quilt push -a )

.PHONY: update-mtn
update-mtn: stamps/OE.mtn
	if [ "${OPENMOKO_MTN_REV}" != "`(cd openembedded && mtn automate get_base_revision_id)`" ] ; then \
		mtn --db=OE.mtn pull monotone.openembedded.org org.openembedded.dev ; \
	fi

.PHONY: update-openembedded
update-openembedded: update-mtn stamps/openembedded
	( cd openembedded && quilt pop -a -f ) || true
	( cd openembedded && mtn revert . )
	@if [ -n "${OPENMOKO_MTN_REV}" -a \
	     "${OPENMOKO_MTN_REV}" != "`(cd openembedded ; mtn automate get_base_revision_id)`" ] ; then \
	  echo "OpenMoko is now using a frozen OE version which doesn't match your OE checkout." ; \
	  echo "You will need to run \"make clobber-openembedded setup-openembedded\" to fix this." ; \
	  echo "Unfortunately, this will force a complete rebuild of *everything* (it's unavoidable)." ; \
	  echo "Alternatively, comment out the OPENMOKO_MTN_REV definition to use unofficial OE head." ; \
	  false ; \
	fi
	( cd openembedded && mtn update ${MTN_REV_FLAGS} ) || \
	( cd openembedded && mtn update \
		-r `mtn automate heads | head -n1` )
	[ ! -e patches/openembedded-${OPENMOKO_MTN_REV} ] || \
	( cd openembedded && rm -f patches && \
	  ln -sfn ../patches/openembedded-${OPENMOKO_MTN_REV} patches )
	[ ! -e openembedded/patches/series ] || \
	( cd openembedded && quilt push -a )

.PHONY: update-patches
update-patches: stamps/patches
	( cd patches && svn update )

.PHONY: update-openmoko
update-openmoko: stamps/openmoko
	( cd openmoko && quilt pop -a -f ) || true
	( cd openmoko && svn revert -R . )
	( cd openmoko && svn update -r ${OPENMOKO_SVN_REV} )
	[ ! -e patches/openmoko-${OPENMOKO_SVN_REV} ] || \
	( cd openmoko && rm -f patches && \
	  ln -sfn ../patches/openmoko-${OPENMOKO_SVN_REV} patches )
	[ ! -e openmoko/patches/series ] || \
	( cd openmoko && quilt push -a )

.PHONY: openmoko-devel-image
openmoko-devel-image stamps/openmoko-devel-image: \
		stamps/openmoko stamps/bitbake \
		stamps/openembedded stamps/patches \
		build/conf/local.conf setup-env
	( cd build && . ../setup-env && \
	  bitbake openmoko-devel-image )
	[ -d stamps ] || mkdir stamps
	touch stamps/openmoko-devel-image

.PHONY: openmoko-host-tools
openmoko-devel-tools: \
		stamps/openmoko stamps/bitbake \
		stamps/openembedded stamps/patches \
		build/conf/local.conf setup-env
	( cd build && . ../setup-env && \
	  bitbake dfu-util-native openocd-native )

.PHONY: qemu
qemu: setup-qemu build-qemu download-images flash-qemu-official run-qemu

.PHONY: setup-qemu
setup-qemu stamps/qemu: \
		stamps/openmoko stamps/patches
	[ -e build/qemu ] || \
	( cd build && mkdir -p qemu )
	[ -e build/qemu/Makefile ] || \
	( . ./setup-env && cd build/qemu && \
	  $${OMDIR}/openmoko/trunk/src/host/qemu-neo1973/configure \
		--target-list=arm-softmmu )
	[ -e build/qemu/openmoko ] || \
	( . ./setup-env && cd build/qemu && mkdir openmoko && \
	  for f in $${OMDIR}/openmoko/trunk/src/host/qemu-neo1973/openmoko/* ; do \
	    ln -s $$f openmoko/`basename $$f` ; \
	  done )
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
	( cd build/qemu && openmoko/flash.sh ../tmp/deploy/images )

.PHONY: run-qemu
run-qemu: stamps/qemu 
	( cd build/qemu && arm-softmmu/qemu-system-arm \
		-M neo -m 130 -usb -show-cursor \
		-usbdevice keyboard \
		-mtdblock openmoko/openmoko-flash.image \
		-kernel openmoko/openmoko-kernel.bin )

.PHONY: run-qemu-snapshot
run-qemu-snapshot: stamps/qemu 
	( cd build/qemu && arm-softmmu/qemu-system-arm \
		-M neo -m 130 -usb -show-cursor -snapshot \
		-usbdevice keyboard \
		-mtdblock openmoko/openmoko-flash.image \
		-kernel openmoko/openmoko-kernel.bin )

.PHONY: run-qemu-vnc
run-qemu-vnc: stamps/qemu 
	( cd build/qemu && arm-softmmu/qemu-system-arm \
		-M neo -m 130 -usb -show-cursor \
		-vnc localhost:1 -monitor stdio \
		-mtdblock openmoko/openmoko-flash.image \
		-kernel openmoko/openmoko-kernel.bin )

.PHONY: push-makefile
push-makefile:
	scp Makefile www.rwhitby.net:htdocs/files/openmoko/Makefile

.PHONY: push-openembedded
push-openembedded: update-mtn openembedded/_MTN/revision
	if [ `mtn --db=OE.mtn automate heads org.openembedded.dev | wc -l` \
		!= "1" ] ; then \
	  mtn --db=OE.mtn merge -b org.openembedded.dev ; \
	fi
	( cd openembedded ; mtn update )
	if [ `mtn --db=OE.mtn automate heads org.openembedded.dev | wc -l` \
		!= "1" ] ; then \
	  mtn --db=OE.mtn merge -b org.openembedded.dev ; \
	fi
	( cd openembedded && mtn push monotone.openembedded.org org.openembedded.dev )

.PHONY: build-package-%
build-package-%:
	( . ./setup-env && cd build && bitbake -c build $* )

.PHONY: rebuild-package-%
rebuild-package-%:
	( . ./setup-env && cd build && bitbake -c rebuild $* )

.PHONY: clean-package-%
clean-package-%:
	( . ./setup-env && cd build && bitbake -c clean $* )

.PHONY: clobber
clobber: clobber-openembedded clobber-qemu

.PHONY: clobber-openembedded
clobber-openembedded:
	rm -rf build/tmp openembedded stamps/openembedded stamps/openmoko-devel-image

.PHONY: clobber-qemu
clobber-qemu:
	rm -rf build/qemu stamps/qemu
