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
# OPENMOKO_MTN_REV = e2dbb52fe39df7ef786b6068f6178f29508dfded

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
all: openmoko-devel-image openmoko-devel-tools

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
update: update-mtn update-openembedded update-patches update-bitbake update-openmoko

.PHONY: setup-bitbake
setup-bitbake bitbake/bin/bitbake:
	[ -e bitbake ] || \
	( svn co -r ${BITBAKE_SVN_REV} svn://svn.berlios.de/bitbake/branches/bitbake-1.6 bitbake )

.PHONY: setup-mtn
setup-mtn OE.mtn:
	[ -e OE.mtn ] || \
	( ( wget -c -O OE.mtn.bz2 ${OE_SNAPSHOT_SITE}/${OE_SNAPSHOT_NAME} || \
	    wget -c -O OE.mtn.bz2 ${OE_SNAPSHOT_SITE}/OE.mtn.bz2 ) && \
	  bunzip2 OE.mtn.bz2 && \
	  mtn --db=OE.mtn db migrate && \
	  mtn --db=OE.mtn pull monotone.openembedded.org org.openembedded.dev )

.PHONY: setup-openembedded
setup-openembedded openembedded/_MTN/revision: OE.mtn
	[ -e openembedded/_MTN/revision ] || \
	( mtn --db=OE.mtn checkout --branch=org.openembedded.dev \
		${MTN_REV_FLAGS} openembedded ) || \
	( mtn --db=OE.mtn checkout --branch=org.openembedded.dev \
		-r `mtn --db=OE.mtn automate heads | head -n1` openembedded )
	touch openembedded/_MTN/revision

.PHONY: setup-openmoko
setup-openmoko openmoko/trunk/oe/conf/site.conf:
	[ -e openmoko ] || \
	( svn co -r ${OPENMOKO_SVN_REV} http://svn.openmoko.org/ openmoko )
	[ -e oe ] || \
	( ln -sfn openmoko/trunk/oe . )

.PHONY: setup-patches
setup-patches: openmoko/trunk/oe/conf/site.conf
	[ -e patches ] || \
	( svn co http://${MM_SVN_SITE}/${MM_SVN_PATH}/trunk/patches patches )
	[ -e bitbake/patches ] && \
	( cd bitbake ; quilt pop -a -f ) || true
	( cd bitbake ; svn revert -R . )
	[ -e openmoko/patches ] && \
	( cd openmoko ; quilt pop -a -f ) || true
	( cd openmoko ; svn revert -R . )
	[ ! -e patches/bitbake-${BITBAKE_SVN_REV} ] || \
	( cd bitbake ; rm -f patches ; \
	  ln -sfn ../patches/bitbake-${BITBAKE_SVN_REV} patches )
	[ ! -e patches/openmoko-${OPENMOKO_SVN_REV} ] || \
	( cd openmoko ; rm -f patches ; \
	  ln -sfn ../patches/openmoko-${OPENMOKO_SVN_REV} patches )
	[ ! -e openmoko/patches/series ] || \
	( cd openmoko ; quilt push -a )
	[ ! -e bitbake/patches/series ] || \
	( cd bitbake ; quilt push -a )

.PHONY: setup-config
setup-config build/conf/local.conf:
	mkdir -p build/conf
	[ -e build/conf/local.conf ] || \
	( echo 'MACHINE = "fic-gta01"' > build/conf/local.conf ; \
	  echo 'DISTRO = "openmoko"' >> build/conf/local.conf ; \
	  echo 'BUILD_ARCH = "'`uname -m`'"' >> build/conf/local.conf )

setup-env:
	[ -e setup-env ] || \
	( echo 'export OMDIR="'`pwd`'"' > setup-env ; \
	  echo \
	'export BBPATH="$${OMDIR}/build:$${OMDIR}/oe:$${OMDIR}/openembedded"' \
		>> setup-env ; \
	  echo \
	'export PYTHONPATH="$${OMDIR}/bitbake/libbitbake"' \
		>> setup-env ; \
	  echo \
	'export PATH="$${OMDIR}/bitbake/bin:$${PATH}"' \
		>> setup-env )

.PHONY: update-makefile
update-makefile:
	( rm -rf Makefile.old ; \
	  mv Makefile Makefile.old ; \
	  wget http://www.rwhitby.net/files/openmoko/Makefile && \
	  rm -f Makefile.old )

.PHONY: check-makefile
check-makefile:
	( wget -q -O - http://www.rwhitby.net/files/openmoko/Makefile | \
	  diff -u Makefile - )

.PHONY: update-bitbake
update-bitbake: bitbake/bin/bitbake
	( cd bitbake ; quilt pop -a -f ) || true
	( cd bitbake ; svn revert -R . )
	( cd bitbake ; svn update -r ${BITBAKE_SVN_REV} )
	[ ! -e patches/bitbake-${BITBAKE_SVN_REV} ] || \
	( cd bitbake ; rm -f patches ; \
	  ln -sfn ../patches/bitbake-${BITBAKE_SVN_REV} patches )
	[ ! -e bitbake/patches/series ] || \
	( cd bitbake ; quilt push -a )

.PHONY: update-mtn
update-mtn: OE.mtn
	mtn --db=OE.mtn pull monotone.openembedded.org org.openembedded.dev

.PHONY: update-openembedded
update-openembedded: update-mtn openembedded/_MTN/revision
	( cd openembedded ; mtn update ${MTN_REV_FLAGS} ) || \
	( cd openembedded ; mtn update \
		-r `mtn automate heads | head -n1` )

.PHONY: update-patches
update-patches: 
	( cd patches ; svn update )

.PHONY: update-openmoko
update-openmoko: openmoko/trunk/oe/conf/site.conf
	( cd openmoko ; quilt pop -a -f ) || true
	( cd openmoko ; svn revert -R . )
	( cd openmoko ; svn update -r ${OPENMOKO_SVN_REV} )
	[ ! -e patches/openmoko-${OPENMOKO_SVN_REV} ] || \
	( cd openmoko ; rm -f patches ; \
	  ln -sfn ../patches/openmoko-${OPENMOKO_SVN_REV} patches )
	[ ! -e openmoko/patches/series ] || \
	( cd openmoko ; quilt push -a )

.PHONY: openmoko-devel-image
openmoko-devel-image: \
		openmoko/trunk/oe/conf/site.conf \
		bitbake/bin/bitbake \
		openembedded/_MTN/revision \
		build/conf/local.conf \
		setup-env
	( cd build ; . ../setup-env ; \
	  bitbake openmoko-devel-image )

.PHONY: openmoko-host-tools
openmoko-devel-tools: \
		openmoko/trunk/oe/conf/site.conf \
		bitbake/bin/bitbake \
		openembedded/_MTN/revision \
		build/conf/local.conf \
		setup-env
	( cd build ; . ../setup-env ; \
	  bitbake dfu-util-native openocd-native )

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
	( cd openembedded ; mtn push monotone.openembedded.org org.openembedded.dev )

.PHONY: build-package-%
build-package-%:
	( source ./setup-env ; cd build ; bitbake -c build $* )

.PHONY: clean-package-%
clean-package-%:
	( source ./setup-env ; cd build ; bitbake -c clean $* )

.PHONY: clobber
clobber:
	rm -rf build/tmp
