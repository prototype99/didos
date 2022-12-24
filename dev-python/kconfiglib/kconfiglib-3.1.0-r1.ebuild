# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:ulfalizer"
GH_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Flexible Python Kconfig parser and library"
LICENSE="ISC"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( examples )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

python_install_all() {
	distutils-r1_python_install_all

	use examples && \
		dodoc -r examples
}
