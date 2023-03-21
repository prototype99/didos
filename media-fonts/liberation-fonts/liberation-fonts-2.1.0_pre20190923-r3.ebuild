# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( py{py3,thon3_{5..7}} )

inherit font python-any-r1

NUM="bc729192aefce4cab6c67b61832ee430e7f54181"
DESCRIPTION="A Helvetica/Times/Courier/Arial replacement TrueType font, courtesy of Red Hat"
HOMEPAGE="https://github.com/liberationfonts/liberation-fonts"
#if you don't use fontforge you get the old 2.00.5 version sorry! also not tested...
#let me know if it's successful and i'll remove this, saving precious storage space
SRC_URI="!fontforge? ( ${HOMEPAGE}/files/2926169/${PN}-ttf-2.00.5.tar.gz )
fontforge? ( ${HOMEPAGE}/archive/${NUM}.zip -> ${P}.zip )"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~x86 ~x64-cygwin ~amd64-linux ~x86-linux ~x64-solaris"
SLOT="0"
LICENSE="OFL-1.1"
IUSE="fontforge vanilla X"

FONT_SUFFIX="ttf"

FONT_CONF=(
	"${FILESDIR}/60-liberation-arial.conf"
	"${FILESDIR}/60-liberation-courier.conf"
	"${FILESDIR}/60-liberation-helvetica.conf"
	"${FILESDIR}/60-liberation-times.conf"
)

DEPEND="
	fontforge? (
		${PYTHON_DEPS}
		media-gfx/fontforge
		dev-python/fonttools
	)"

S="${WORKDIR}/${PN}-${NUM}"

pkg_setup() {
	if use fontforge; then
		FONT_S="${S}/${PN}-ttf-2.00.5"
		python-any-r1_pkg_setup
	else
		FONT_S="${WORKDIR}/${PN}-ttf-2.00.5"
		S="${FONT_S}"
	fi
	font_pkg_setup
}

src_prepare() {
	use fontforge && use !vanilla && eapply "${FILESDIR}"/glyph.patch
	default
}