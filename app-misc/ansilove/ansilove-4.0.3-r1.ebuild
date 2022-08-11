# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS src_prepare src_configure src_compile src_test src_install
inherit cmake

DESCRIPTION="ANSi/ASCII art to PNG converter in C"
HOMEPAGE_A=(
	"https://www.ansilove.org/"
	"${GH_HOMEPAGE}"
)
LICENSE="BSD-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
	"media-libs/libansilove:0="
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays
