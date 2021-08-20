# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:jquast"

## python-*.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5,6,7}}} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Library that measures the width of unicode strings rendered to a terminal"
LICENSE="MIT"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"app-i18n/unicode-data:*"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=dev-python/six-1.9.0[${PYTHON_USEDEP}]"
	"dev-python/wcwidth[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	# do not fetch remote data
	rsed -e '/self._do_retrieve/d' -i -- setup.py
	# no tests
	rsed -r -e "s|, *'wcwidth.tests'||" -i -- setup.py

	rmkdir data
	rln -s /usr/share/unicode-data/EastAsianWidth.txt data/
	rln -s /usr/share/unicode-data/extracted/DerivedGeneralCategory.txt data/

	distutils-r1_python_prepare_all
}
