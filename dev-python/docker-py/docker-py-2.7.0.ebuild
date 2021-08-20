# Copyright 1999-2019 Gentoo Authors
# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:docker"

## python-r1.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

## EXPORT_FUNCTIONS: src_unpack
## variables: HOMEPAGE, SRC_URI
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Python client for Docker"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="amd64 arm64"
IUSE="doc test"

RDEPEND="
	>=dev-python/docker-pycreds-0.2.1[${PYTHON_USEDEP}]
	!~dev-python/requests-2.18.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.14.2[${PYTHON_USEDEP}]
	>=dev-python/six-1.4.0[${PYTHON_USEDEP}]
	>=dev-python/websocket-client-0.32.0[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '>=dev-python/backports-ssl-match-hostname-3.5[${PYTHON_USEDEP}]' 'python2_7' )
	$(python_gen_cond_dep '>=dev-python/ipaddress-1.0.16[${PYTHON_USEDEP}]' 'python2_7' )
"
DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		${RDEPEND}
		>=dev-python/mock-1.0.1[${PYTHON_USEDEP}]
		dev-python/pytest-runner[${PYTHON_USEDEP}]
		>=dev-python/pytest-2.9.1[${PYTHON_USEDEP}]
	)
	doc? (
		dev-python/recommonmark[${PYTHON_USEDEP}]
		>=dev-python/sphinx-1.4.6[${PYTHON_USEDEP}]
	)
"

python_prepare_all() {
	sed -i -e "s/import pip//" -e "s/if 'docker-py'.*/if False:/" setup.py || die
	distutils-r1_python_prepare_all
}

python_compile_all() {
	if use doc; then
		sphinx-build docs html || die "docs failed to build"
		HTML_DOCS=( html/. )
	fi
}

python_test() {
	py.test tests/unit/ || die "tests failed under ${EPYTHON}"
}
