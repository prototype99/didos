# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:WoLpH"
GH_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all
## variables: PYTHON_USEDEP
inherit distutils-r1

DESCRIPTION="Convenient utilities not included with the standard Python install"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/six[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	rsed -e "/setup_requires=\['pytest-runner'\]/d" -i -- setup.py

	distutils-r1_python_prepare_all
}
