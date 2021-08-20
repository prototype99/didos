# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:latchset"
GH_REF="v${PV}"

## python-r1.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

## EXPORT_FUNCTIONS: src_unpack
## variables: HOMEPAGE, SRC_URI
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Implementation of JWK,JWS,JWE specifications using python-cryptography"
LICENSE="LGPL-3+"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
)

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"=dev-python/cryptography-2*[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	rsed -e '/data_files/d' -i -- setup.py
	rrm "${PN}"/*tests*

	distutils-r1_python_prepare_all
}
