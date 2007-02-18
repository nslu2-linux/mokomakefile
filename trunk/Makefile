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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

OPENMOKO_SVN_REV = 1004
OPENMOKO_MTN_REV = f499733e6db527846e1a48cf70f9862d6b3798ae

MTN_VERSION := $(shell mtn --version | awk '{ print $$2; }')

.PHONY: all
all: openmoko-devel-image

.PHONY: setup
setup:  setup-openmoko setup-bitbake setup-monotone setup-openembedded \
	setup-sources setup-config setup-env

.PHONY: update
update: update-openmoko update-bitbake update-mtn update-openembedded

.PHONY: setup-openmoko
setup-openmoko openmoko/trunk/oe/conf/site.conf:
	[ -e openmoko ] || \
	( svn co -r ${OPENMOKO_SVN_REV} http://svn.openmoko.org/ openmoko )
	[ -e oe ] || \
	( ln -s openmoko/trunk/oe . )
	perl -pi.orig -e 's|trunk/src/target/kernel;|branches/src/target/kernel/2.6.17.14;rev=1003;|' \
		openmoko/trunk/oe/packages/linux/linux-gta01_2.6.17.14.bb
	grep -e 'do_compile_prepend' openmoko/trunk/oe/packages/openmoko-apps/openmoko-mainmenu_svn.bb > /dev/null || \
	( echo "do_compile_prepend() {" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-mainmenu_svn.bb ; \
	  echo "	sed -i -e 's:\$$(AM_LDFLAGS):\$$(AM_LDFLAGS)\ -lmb:' src/Makefile" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-mainmenu_svn.bb ; \
	  echo "}" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-mainmenu_svn.bb )
	grep -e 'do_install_prepend' openmoko/trunk/oe/packages/openmoko-apps/openmoko-simplemediaplayer_svn.bb > /dev/null || \
	( echo "do_install_prepend() {" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-simplemediaplayer_svn.bb ; \
	  echo "	touch mkinstalldirs" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-simplemediaplayer_svn.bb ; \
	  echo "}" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-simplemediaplayer_svn.bb ; \
	  echo >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-simplemediaplayer_svn.bb ; \
	  echo "FILES_\$${PN} += \" \\" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-simplemediaplayer_svn.bb ; \
	  echo "                \$${datadir}/images \\" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-simplemediaplayer_svn.bb ; \
	  echo "		\$${libdir}/bmp/*/*.so \\" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-simplemediaplayer_svn.bb ; \
	  echo "	       \"" >> openmoko/trunk/oe/packages/openmoko-apps/openmoko-simplemediaplayer_svn.bb )
	perl -pi.orig -e 's|DEPENDS \+= "libgsmd"|DEPENDS += "libgsmd eds-dbus"|' \
		openmoko/trunk/oe/packages/openmoko-apps/openmoko-dialer_svn.bb
	# Remove u-boot, cause it's annoyingly rebuilt every time, and doesn't build any more.
	perl -pi.orig -e 's|DEPENDS \+= "quilt-native uboot-gta01"|DEPENDS += "quilt-native"|' \
		openmoko/trunk/oe/packages/linux/linux-gta01_2.6.17.14.bb
	perl -pi.orig -e 's|	uboot-mkimage|	# uboot-mkimage|' \
		openmoko/trunk/oe/packages/linux/linux-gta01_2.6.17.14.bb

.PHONY: setup-bitbake
setup-bitbake bitbake/bin/bitbake:
	[ -e bitbake ] || \
	( svn co svn://svn.berlios.de/bitbake/branches/bitbake-1.6 bitbake )

.PHONY: setup-monotone
setup-monotone OE.mtn:
	[ -e OE.mtn ] || \
	( wget -O OE.mtn.bz2 http://www.openembedded.org/snapshots/OE-this-is-for-mtn-${MTN_VERSION}.mtn.bz2 && \
	  bunzip2 OE.mtn.bz2 )
	mtn --db=OE.mtn pull monotone.openembedded.org org.openembedded.dev

.PHONY: setup-openembedded
setup-openembedded openembedded/_MTN/revision: OE.mtn
	[ -e openembedded/_MTN/revision ] || \
	( mtn --db=OE.mtn checkout --branch=org.openembedded.dev \
		-r ${OPENMOKO_MTN_REV} openembedded )
	perl -pi.orig -e 's/ *$$//;s/\r//g' \
		openembedded/packages/gcc/gcc-4.1.1/gcc-4.1.1-pr13685-1.patch
	touch openembedded/_MTN/revision

.PHONY: setup-sources
setup-sources:
	mkdir -p sources
	[ -e sources/js-1.5.tar.gz ] || \
	( cd sources ; \
	  wget http://ftp.mozilla.org/pub/mozilla.org/js/older-packages/js-1.5.tar.gz )
	[ -e sources/samba-3.0.14a.tar.gz ] || \
	( cd sources ; \
	  wget http://us4.samba.org/samba/ftp/stable/samba-3.0.14a.tar.gz )

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
	  echo 'export BBPATH="$${OMDIR}/build:$${OMDIR}/openmoko/trunk/oe:$${OMDIR}/openembedded"' >> setup-env ; \
	  echo 'export PYTHONPATH="$${OMDIR}/bitbake/libbitbake"' >> setup-env ; \
	  echo 'export PATH="$${OMDIR}/bitbake/bin:${PATH}"' >> setup-env )

.PHONY: update-makefile
update-makefile:
	( rm -rf Makefile.old ; \
	  mv Makefile Makefile.old ; \
	  wget http://www.rwhitby.net/files/openmoko/Makefile && \
	  rm -f Makefile.old )

.PHONY: check-makefile
check-makefile:
	( wget -q -O - http://www.rwhitby.net/files/openmoko/Makefile | diff -u Makefile - )

.PHONY: update-openmoko
update-openmoko: openmoko/trunk/oe/conf/site.conf
	( cd openmoko ; svn update -r ${OPENMOKO_SVN_REV} )

.PHONY: update-bitbake
update-bitbake: bitbake/bin/bitbake
	( cd bitbake ; svn update )

.PHONY: update-mtn
update-mtn: OE.mtn
	mtn --db=OE.mtn pull monotone.openembedded.org org.openembedded.dev

.PHONY: update-openembedded
update-openembedded: update-mtn openembedded/_MTN/revision
	if [ `mtn --db=OE.mtn automate heads org.openembedded.dev | wc -l` != "1" ] ; then \
	  mtn --db=OE.mtn merge -b org.openembedded.dev ; \
	fi
	( cd openembedded ; mtn update -r ${OPENMOKO_MTN_REV} )
	if [ `mtn --db=OE.mtn automate heads org.openembedded.dev | wc -l` != "1" ] ; then \
	  mtn --db=OE.mtn merge -b org.openembedded.dev ; \
	fi

.PHONY: openmoko-devel-image
openmoko-devel-image: \
		openmoko/trunk/oe/conf/site.conf \
		bitbake/bin/bitbake \
		openembedded/_MTN/revision \
		build/conf/local.conf \
		setup-env
	( cd build ; . ../setup-env ; \
	  bitbake openmoko-devel-image )

.PHONY: push-makefile
push-makefile:
	scp Makefile www.rwhitby.net:htdocs/files/openmoko/Makefile

.PHONY: clobber
clobber:
	rm -rf build/tmp
