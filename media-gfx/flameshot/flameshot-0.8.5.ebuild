# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake toolchain-funcs xdg-utils

DESCRIPTION="Powerful yet simple to use screenshot software"
HOMEPAGE="https://flameshot.js.org"
SRC_URI="https://github.com/lupoDharkael/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="FreeArt GPL-3 Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

IUSE="+dbus"

CMAKE_MIN_VERSION=3.13

DEPEND="
	>=dev-qt/qtcore-5.9:5
	dev-qt/qtgui:5
	dev-qt/qtsingleapplication[qt5(+),X]
	>=dev-qt/qtwidgets-5.9:5
	>=dev-qt/qtsvg-5.9:5
	>=dev-qt/qtnetwork-5.9:5
	dbus? (
		>=dev-qt/qtdbus-5.9:5
		sys-apps/dbus
	)
"
BDEPEND="
	>=dev-qt/linguist-tools-5.9:5
"
RDEPEND="${DEPEND}"
pkg_pretend(){
	if tc-is-gcc && ver_test "$(gcc-version)" -lt 7.4 ;then
		die "You need at least GCC 7.4 to build this package"
	fi
}

src_install(){
	emake INSTALL_ROOT="${D}" install
}

pkg_postinst(){
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}

pkg_postrm(){
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}
