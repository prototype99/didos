# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

# linux-info.eclass
CONFIG_CHECK="USB_MON"
# git-hosting.eclass:
GH_RN="github:aguinet"
GH_REF="release-${PV}"

# EXPORT_FUNCTIONS: pkg_setup
inherit linux-info
# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake

DESCRIPTION="utility that shows an estimated instantaneous bandwidth on USB buses and devices"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc )

CDEPEND_A=(
	"net-libs/libpcap"
	"dev-libs/boost[threads]"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply "${FILESDIR}"/0.1-bdac07fdafa689e06e6e54fcfea0008a07b0a27c.patch
	eapply "${FILESDIR}"/0.1-5027b13b813e30886da9ca1322bcf7392f356cdb.patch
	eapply "${FILESDIR}"/0.1-22730b09b57a763c4c7f69f5126d2648ec1a378f.patch
	eapply_user

	sed -e '/add_definitions/ s|-O3||' -i -- src/CMakeLists.txt || die

	cmake_src_prepare
}
