# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="${P}"

## python-r1.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

## EXPORT_FUNCTIONS: src_unpack
## variables: HOMEPAGE, SRC_URI
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Creation, manipulation, and study of complex networks"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=()

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"=dev-python/decorator-4*[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	# don't install tests
	rsed -e "/package_data=package_data,/d" -i -- setup.py

	# don't install examples
	rsed -e "/data.append((dd/d" -i -- setup.py

	# don't use tests in runtime
	rsed -e "/networkx.tests/d" -i -- ${PN}/__init__.py

	distutils-r1_python_prepare_all
}
