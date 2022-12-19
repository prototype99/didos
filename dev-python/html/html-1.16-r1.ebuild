# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

PYTHON_COMPAT=( py{thon2_7,py3} )

inherit distutils-r1

DESCRIPTION="Simple, elegant HTML, XHTML and XML generation"
HOMEPAGE="https://pypi.python.org/pypi/html"
LICENSE="BSD"

SLOT="0"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

KEYWORDS="amd64 arm arm64"

inherit arrays
