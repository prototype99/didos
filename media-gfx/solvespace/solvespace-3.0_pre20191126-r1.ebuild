# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 cmake

# NOTE: please keep commit hash actually when version up
EGIT_COMMIT="dcdfdec564fc2ab1e087cdc56d017162a05cf778"

DESCRIPTION="Parametric 2d/3d CAD"
HOMEPAGE="http://${PN}.com"
EGIT_REPO_URI="https://github.com/${PN}/${PN}"
EGIT_SUBMODULES=( '*libdxfrw' 'extlib/q3d' )

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="spacenav"

RDEPEND="spacenav? ( dev-libs/libspnav )
	dev-cpp/gtkmm:3.0
	dev-cpp/pangomm
	dev-libs/flatbuffers
	dev-libs/json-c:=
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glu
	media-libs/libpng:0=
	x11-libs/cairo"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

CMAKE_REMOVE_MODULES_LIST="Findflatbuffers"

src_prepare() {
	eapply "${FILESDIR}"/system-flatbuffers.patch
	eapply "${FILESDIR}"/system-flatc.patch
	sed -i '/include(GetGitCommitHash)/d' CMakeLists.txt || die 'remove GetGitCommitHash by sed failed'
	cmake_src_prepare
}

CMAKE_BUILD_TYPE="Release"

src_configure() {
	local mycmakeargs=(
		-DGIT_COMMIT_HASH="${EGIT_COMMIT}"
		-DENABLE_TESTS=OFF
	)
	cmake_src_configure
}
