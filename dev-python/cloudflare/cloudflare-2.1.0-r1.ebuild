# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:cloudflare:python-cloudflare"

## python-*.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all
inherit distutils-r1

DESCRIPTION="Python wrapper for the Cloudflare Client API v4"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/future[${PYTHON_USEDEP}]"
	"dev-python/requests[${PYTHON_USEDEP}]"
	"dev-python/pyyaml[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	rsed -r -e "/packages *=/ s|\[[^]]*\]\+||" -i -- setup.py

	rrm -r examples

	distutils-r1_python_prepare_all
}
