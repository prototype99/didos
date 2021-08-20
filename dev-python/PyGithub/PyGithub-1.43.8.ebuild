# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting,eclass:
GH_RN="github"
GH_REF="v${PV}"

PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

inherit git-hosting

inherit distutils-r1

DESCRIPTION="Python library to access the Github API v3"
HOMEPAGE_A=(
	"${GH_HOMEPAGE}"
)
LICENSE="LGPL-3"

SLOT="0"
SRC_URI_A=(
	"${SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=()

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/pyjwt[${PYTHON_USEDEP}]"
	"dev-python/deprecated[${PYTHON_USEDEP}]"
	"dev-python/requests[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	distutils-r1_python_prepare_all
}
