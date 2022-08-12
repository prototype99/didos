# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:Snaipe"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake

DESCRIPTION="Cross-platform C and C++ unit testing framework for the 21th century"
LICENSE="MIT"

SLOT="0"
klib_ref="56eb0a09a4be92471e62d3bb945e444ebd167615"
SRC_URI+=" https://github.com/attractivechaos/klib/archive/${klib_ref}.tar.gz -> klib-${klib_ref}.tar.gz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( +cpp theories test nls )

CDEPEND_A=(
	"dev-libs/nanopb"
	"dev-libs/libcsptr"
	"dev-libs/nanomsg"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_unpack() {
	git-hosting_src_unpack
	git-hosting_unpack "${DISTDIR}/klib-${klib_ref}.tar.gz" "${S}/dependencies/klib"
}

src_prepare() {
	eapply_user

	rsed -e "\,dependencies/nanopb,d" -i -- src/CMakeLists.txt
	rsed -r -e 's!struct bxf_spawn_params!struct bxf_spawn_params_s!' -i -- src/core/runner_coroutine.c
	rsed -r -e "/\bDESTINATION\b/ s,\blib\b,$(get_libdir)," -i -- .cmake/Modules/PackageUtils.cmake

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D LANG_CXX=$(usex cpp)
		-D THEORIES=$(usex theories)
		-D CTESTS=$(usex test)
		-D I18N=$(usex nls)
	)

	cmake_src_configure
}
