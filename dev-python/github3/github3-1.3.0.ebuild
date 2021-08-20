# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:sigmavirus24:github3.py"

## python-r1.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

## EXPORT_FUNCTIONS: src_unpack
## variables: HOMEPAGE, SRC_URI
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Wrapper around the GitHub API (v3)"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
)

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"=dev-python/requests-2*[${PYTHON_USEDEP}]"
	"=dev-python/uritemplate-3*[${PYTHON_USEDEP}]"
	"=dev-python/python-dateutil-2*[${PYTHON_USEDEP}]"
	"=dev-python/jwcrypto-0*[${PYTHON_USEDEP}]"
)

inherit arrays
