# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## python-*.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{4,5,6,7}}} )

## git-hosting.eclass:
GH_RN="github:takluyver"
GH_REF="cff13f5"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Backwards compatible callback APIs"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

python_prepare_all() {
	# revert switch from disutils to flit
	eapply -R "${FILESDIR}"/c5567120518c13b69a5b1ab453055e4a5af8485a.patch

	distutils-r1_python_prepare_all
}
