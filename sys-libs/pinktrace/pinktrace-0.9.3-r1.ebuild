# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="ptrace() easy wrapper library"
HOMEPAGE="https://dev.exherbo.org/~alip/pinktrace/"
SRC_URI="https://github.com/sydbox/${PN}/archive/refs/tags/v0.9.3.tar.gz"

LICENSE="BSD"
SLOT="0/0.9"
KEYWORDS="~amd64"
IUSE="ipv6"

src_configure() {
	local myconf=(
		$(use_enable ipv6)
		--disable-doxygen
		--disable-python
		--disable-python-doc
		--disable-static
	)

	econf "${myconf[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
