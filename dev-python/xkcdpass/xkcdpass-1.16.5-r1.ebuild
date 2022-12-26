# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:redacted:XKCD-password-generator"
GH_REF="${PN}-${PV}"

## python-*.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5,6,7}}} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_install_all
inherit distutils-r1
# functions: newbashcomp
inherit bash-completion-r1

DESCRIPTION="Flexible and scriptable password generator, inspired by XKCD 936"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="examples"

python_install_all() {
	distutils-r1_python_install_all

	doman "${PN}.1"

	newbashcomp "contrib/${PN}.bash-completion" "${PN}"

	use examples && \
		dodoc -r examples
}
