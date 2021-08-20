# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## python-*.eclass:
PYTHON_COMPAT=( py{py3,thon{2_7,3_{5,6,7}}} )

## git-hosting.eclass:
GH_RN="github:jeffkaufman"
# GH_REF="release-${PV}"
GH_REF="581e60a"  # 20190718

## EXPORT_FUNCTIONS: pkg_setup
inherit python-single-r1

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Colourized diff that supports side-by-side diffing"
HOMEPAGE_A=(
	"https://www.jefftk.com/icdiff"
	"${GH_HOMEPAGE}"
)
LICENSE="PSF-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
	"${PYTHON_DEPS}"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"

)

REQUIRED_USE_A=( "${PYTHON_REQUIRED_USE}" )
RESTRICT+=""

inherit arrays

src_install() {
	dobin ${PN} git-${PN}

	einstalldocs
}
