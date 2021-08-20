# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## python-*.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

## git-hosting.eclass:
GH_RN='github:python-gitlab:python-gitlab'
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all, distutils-r1_python_install_all
## variables: PYTHON_USEDEP
inherit distutils-r1

DESCRIPTION="Python wrapper for the GitLab API"
HOMEPAGE_A=(
	"https://python-gitlab.readthedocs.io"
	"${GH_HOMEPAGE}"
)
LICENSE_A=(
	"LGPL-3"
)

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	man
)

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"man? ( dev-python/sphinx[${PYTHON_USEDEP}] )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">dev-python/requests-1[${PYTHON_USEDEP}]"
	"dev-python/six[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	NO_V=1 rrm -r 'gitlab/tests'

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use man && \
		emake -C docs man
}

python_install_all() {
	distutils-r1_python_install_all

	use man && \
		doman 'docs/_build/man/python-gitlab.1'
}
