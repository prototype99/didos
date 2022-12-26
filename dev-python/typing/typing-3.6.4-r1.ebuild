# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:python"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 pypy{,3} )

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Type Hints for Python"
HOMEPAGE="${GH_HOMEPAGE} https://docs.python.org/3/library/typing.html"
LICENSE="PSF-2"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=(
	# compatibility with broken Gentoo packages which depend on these USE-flags
	python_targets_python3_{5,6}
)

inherit arrays

python_test() {
	cd "${BUILD_DIR}" || die

	if [[ ${EPYTHON} == python2* || ${EPYTHON} == pypy ]] ; then
		rcp "${S}"/python2/test_typing.py .
	else
		rcp "${S}"/src/test_typing.py .
	fi

	"${EPYTHON}" test_typing.py || die "tests failed under ${EPYTHON}"
}
