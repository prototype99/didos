# Copyright 1999-2014 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass
GH_RN='github:alexkay'
[[ "${PV}" == *9999* ]] || GH_REF="v${PV}"
## wxwidgets.eclass
WX_GTK_VER="3.0"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: setup-wxwidgets
## variables: WX_GTK_VER
inherit wxwidgets
## EXPORT_FUNCTIONS src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

DESCRIPTION="Analyse your audio files by showing their spectrogram"
HOMEPAGE="http://www.spek-project.org/ ${GH_HOMEPAGE}"
LICENSE="GPL-3"

SLOT="0"

[[ "${PV}" == *9999* ]] || \
	KEYWORDS="~amd64"
IUSE_A=( nls )

CDEPEND_A=(
	"media-video/ffmpeg:0="

	"x11-libs/wxGTK:${WX_GTK_VER}[X]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-util/intltool"
	"virtual/pkgconfig"
	"sys-devel/gettext"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

pkg_setup() {
	setup-wxwidgets unicode
}

src_prepare() {
	eapply "${FILESDIR}"/${PN}-0.8.3-replace-gnu+11-with-c++11.patch
	eapply_user

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}
