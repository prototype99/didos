# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## python-any-r1.eclass:
PYTHON_COMPAT=( py{py3,thon3_{5..7}} )

## git-hosting.eclass:
GH_RN="github:KhronosGroup:SPIRV-Tools"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake
## EXPORT_FUNCTIONS: pkg_setup
inherit python-any-r1

DESCRIPTION="API and commands for processing SPIR-V modules"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( compressing-codec color-terminal executables test )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_configure() {
	local mycmakeargs=(
		-D SKIP_SPIRV_TOOLS_INSTALL=OFF
		-D SPIRV_BUILD_COMPRESSION=$(usex compressing-codec)
		-D SPIRV_COLOR_TERMINAL=$(usex color-terminal)
		-D SPIRV_SKIP_EXECUTABLES=$(usex !executables)
		-D SPIRV_SKIP_TESTS=$(usex !test)
		-D SPIRV_CHECK_CONTEXT=OFF  # debugging option

		-D SPIRV-Headers_SOURCE_DIR="/usr"
	)

	cmake_src_configure
}
