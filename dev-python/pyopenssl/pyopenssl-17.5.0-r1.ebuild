# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:pyca"

## python-*.eclass (distutils-r1.eclass):
PYTHON_COMPAT=( python2_7 python3_{5,6,7} pypy{,3} )
PYTHON_REQ_USE="threads(+)"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_install_all
## variables: PYTHON_USEDEP
inherit distutils-r1

DESCRIPTION="Python interface to the OpenSSL library"
HOMEPAGE="
	${GH_HOMEPAGE}
	https://pyopenssl.org/
	https://pyopenssl.readthedocs.io/en/${PV}/
	https://pypi.python.org/pypi/pyOpenSSL
"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc examples test )

CDEPEND_A=(
	">=dev-python/six-1.5.2[${PYTHON_USEDEP}]"
	">=dev-python/cryptography-1.3[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )"
	"test? ("
		"virtual/python-cffi[${PYTHON_USEDEP}]"
		">=dev-python/pytest-3.0.1[${PYTHON_USEDEP}]"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

python_compile_all() {
	use doc && \
		emake -C doc html
}

python_test() {
	esetup.py test
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/_build/html/. )

	distutils-r1_python_install_all

	if use examples ; then
		docinto examples
		dodoc -r examples/*
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
