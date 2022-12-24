# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

GH_RN="github:projectcalico:posix_spawn"

PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

inherit distutils-r1

DESCRIPTION="Python posix_spawn bindings with cffi"
HOMEPAGE="${GH_HOMEPAGE} https://pypi.python.org/pypi/posix-spawn"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/cffi[${PYTHON_USEDEP}]"
)

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays
