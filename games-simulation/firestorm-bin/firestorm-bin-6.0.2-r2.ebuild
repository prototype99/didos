# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit eutils desktop

REVISION=56680

DESCRIPTION="An open source metaverse viewer"
HOMEPAGE="http://www.firestormviewer.org/"

MY_P="Phoenix_FirestormOS-Releasex64_x86_64_${PV}.${REVISION}"
SRC_URI="https://downloads.firestormviewer.org/linux/${MY_P}.tar.xz"

RESTRICT="mirror"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="fmod"

INST_DIR="opt/firestorm-bin"
QA_PREBUILT="${INST_DIR}/*"

RDEPEND="
	sys-libs/glibc
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXinerama
	dev-libs/apr
	dev-libs/libgcrypt
	dev-libs/libgpg-error
	dev-libs/openssl:*
	dev-libs/boost
	media-libs/freetype
	media-libs/libogg
	media-libs/libsdl
	media-libs/libvorbis
	media-libs/gstreamer:*
	media-plugins/gst-plugins-meta:*
	fmod? ( media-libs/fmod )
	net-libs/gnutls
	net-misc/curl
	net-dns/c-ares
	sys-libs/zlib
	virtual/glu
	virtual/opengl
"
DEPEND="${RDEPEND}
	app-admin/chrpath
"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# shouldn't need to null RPATH with chrpath - but scanelf
	# reports 'Security problem NULL DT_RPATH' otherwise
	chrpath -r '' lib/libffi.so.5.0.10
	scanelf -Xr lib/libffi.so.5.0.10
	chrpath -r '' lib/libalut.so.0.0.0
	scanelf -Xr lib/libalut.so.0.0.0

	eapply_user
}

src_install() {
	mkdir -p "${D}/${INST_DIR}/"
	cp -a . "${D}/${INST_DIR}/" || die
	dosym /${INST_DIR}/firestorm /usr/bin/firestorm-bin

	insinto /etc/revdep-rebuild
	doins "${FILESDIR}"/70${PN}

	make_desktop_entry firestorm-bin "Phoenix Firestorm Viewer (bin)" /${INST_DIR}/firestorm_icon.png
}
