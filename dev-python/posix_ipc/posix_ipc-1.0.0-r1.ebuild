# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

PYTHON_COMPAT=( py{py3,thon{2_7,3_{5..7}}} )
# DISTUTILS_IN_SOURCE_BUILD=1

# EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1
inherit flag-o-matic

DESCRIPTION="POSIX IPC primitives (semaphores, shared memory and message queues) for Python"
HOMEPAGE="http://semanchuk.com/philip/${PN}/ https://pypi.python.org/pypi/${PN}"
LICENSE="BSD"

SLOT="0"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="debug"

pkg_setup() {
	use debug && append-cflags "-DPOSIX_IPC_DEBUG"
}

python_prepare_all() {
	# python2 code without preprocessor check
	sed -e '/DPRINTF("PyString_Check/d' -i -- posix_ipc_module.c || die

	distutils-r1_python_prepare_all
}
