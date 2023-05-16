# Copyright 2004-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6..10} )

inherit python-single-r1 xdg cmake

DESCRIPTION="postscript font editor and converter"
HOMEPAGE="https://${PN}.org/"
MY_PV="43e6087ec9bdbb23b8bb61c07efe6490fab23d73"
SRC_URI="https://github.com/${PN}/${PN}/archive/${MY_PV}.zip -> ${P}.zip"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="BSD GPL-3+"
SLOT="0"
IUSE="doc truetype-debugger gif gtk jpeg png python readline test tiff svg unicode woff2 X"
IUSE+=" extras libspiro"
IUSE+=" gui"
RESTRICT="!test? ( test )"

REQUIRED_USE="
	gui? ( ?? ( gtk X ) )
	python? ( ${PYTHON_REQUIRED_USE} )
"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libltdl:0
	dev-libs/libxml2:2=
	>=media-libs/freetype-2.3.7:2=
	gif? ( media-libs/giflib:0= )
	jpeg? ( virtual/jpeg:0 )
	png? ( media-libs/libpng:0= )
	tiff? ( media-libs/tiff:0= )
	truetype-debugger? ( >=media-libs/freetype-2.3.8:2[fontforge,-bindist(-)] )
	gtk? ( >=x11-libs/gtk+-3.10:3 )
	X? (
		>=x11-libs/cairo-1.6:0=
		>=x11-libs/pango-1.10:0=[X]
		x11-libs/libX11:0=
		x11-libs/libXi:0=
	)
	python? ( ${PYTHON_DEPS} )
	readline? ( sys-libs/readline:0= )
	unicode? ( media-libs/libuninameslist:0= )
	woff2? ( media-libs/woff2:0= )
	libspiro? ( media-libs/libspiro )
"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )
"
BDEPEND="
	sys-devel/gettext
	doc? ( >=dev-python/sphinx-2 )
	python? ( ${PYTHON_DEPS} )
	test? ( ${RDEPEND} )
"

pkg_setup() {
	:
}

src_prepare() {
	[[ $(tc-endian) == "big" ]] && eapply "${FILESDIR}"/${PV}-big-endian.patch
	use elibc_musl && eapply "${FILESDIR}"/${PV}-MacServiceReadFDs.patch
	use sparc && eapply "${FILESDIR}"/${PV}-stylemap.patch
	cmake_src_prepare
	default
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_DOCS=$(usex doc ON OFF)
		-DENABLE_LIBGIF=$(usex gif ON OFF)
		-DENABLE_LIBJPEG=$(usex jpeg ON OFF)
		-DENABLE_LIBPNG=$(usex png ON OFF)
		-DENABLE_LIBREADLINE=$(usex readline ON OFF)
		-DENABLE_LIBSPIRO=$(usex libspiro ON OFF)
		-DENABLE_LIBTIFF=$(usex tiff ON OFF)
		-DENABLE_LIBUNINAMESLIST=$(usex unicode ON OFF)
		-DENABLE_MAINTAINER_TOOLS=OFF
		-DENABLE_PYTHON_EXTENSION=$(usex python ON OFF)
		-DENABLE_GUI=$(usex gui ON OFF)
		-DENABLE_X11=$(usex X ON OFF)
		-DENABLE_PYTHON_SCRIPTING=$(usex python ON OFF)
		-DENABLE_TILE_PATH=ON
		-DENABLE_WOFF2=$(usex woff2 ON OFF)
		-DENABLE_FONTFORGE_EXTRAS=$(usex extras)
	)

	if use python; then
		python_setup
		mycmakeargs+=( -DPython3_EXECUTABLE="${PYTHON}" )
	fi

	if use truetype-debugger ; then
		local ft2="${ESYSROOT}/usr/include/freetype2"
		local ft2i="${ft2}/internal4fontforge"
		mycmakeargs+=(
			-DENABLE_FREETYPE_DEBUGGER="${ft2}"
			-DFreeTypeSource_INCLUDE_DIRS="${ft2};${ft2i}/include;${ft2i}/include/freetype;${ft2i}/src/truetype"
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install
	docompress -x /usr/share/doc/${PF}/html
	einstalldocs
	find "${ED}" -name '*.la' -type f -delete || die
}
