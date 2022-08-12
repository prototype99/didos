# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:KhronosGroup:SPIRV-Headers"
GH_REF="02ffc719aa9f9c1dce5ce05743fb1afe6cbf17ea"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake

DESCRIPTION="SPIR-V Registry header files"
LICENSE="MIT"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_configure() {
	local mycmakeargs=(
		-D CMAKE_INSTALL_PREFIX="${ED}/usr"
	)

	cmake_src_configure
}

src_compile() { : ; }

src_install() {
	_cmake_check_build_dir
	rpushd "${BUILD_DIR}"
	${CMAKE_BINARY} --build . --target install-headers
	rpopd

	einstalldocs
}
