# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="bitbucket:jgehrcke"

## python-*.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Child process management and IPC in the context of gevent"
HOMEPAGE="https://gehrcke.de/gipc ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

# requirements in `gdrivefs/resources/requirements.txt`
CDEPEND_A=(
	">=dev-python/gevent-1.1[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays
