# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit toolchain-funcs

DESCRIPTION="FreeDesktop trayicon area for Ion3"
HOMEPAGE="http://code.google.com/p/trayion/"
SRC_URI="https://github.com/laynor/trayion/archive/v${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="x11-libs/libX11"

src_compile() {
	export X11CFLAGS=' -I/usr/include/X11'
	export X11LDFLAGS=' -L/usr/lib/X11 -lX11'
	make
	# -j1 CC=$(tc-getCC) CFLAGS="${CFLAGS}"
}

src_install() {
	die 'test'
	dobin trayicon
	doman trayicon.1
	dodoc AUTHORS README
}
