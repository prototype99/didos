# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

GH_RN="github:scott-griffiths"
GH_REF="${PN}-${PV}"

PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Python module for creation and analysis of binary data"
HOMEPAGE="https://pythonhosted.org/${PN}/ https://pypi.python.org/pypi/${PN} ${GH_HOMEPAGE}"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

DOCS=( README.rst release_notes.txt )
