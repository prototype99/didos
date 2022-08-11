# Copyright 2016, 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:Kaffeine"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake

DESCRIPTION="Telegram binding for Qt"
LICENSE="LGPL-2.1+"

SLOT="0/0.2"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( widgets-client qml-import doc generator debug )

CDEPEND_A=(
	"dev-qt/qtcore:5"
	"dev-qt/qtnetwork:5"
	"widgets-client? ("
		"dev-qt/qtgui:5"
		"dev-qt/qtwidgets:5"
	")"
	"dev-libs/openssl:0"
	"sys-libs/zlib:0"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

CMAKE_USE_DIR="${S}"
BUILD_DIR="${WORKDIR}/telegram-qt-build"

src_configure() {
	local mycmakeargs=(
		-D ENABLE_TESTS=FALSE
		-D BUILD_WIDGETS_CLIENT=$(usex widgets-client)
		-D ENABLE_QML_IMPORT=$(usex qml-import)
		-D ENABLE_QCH_BUILD=$(usex doc)
		-D STATIC_BUILD=OFF
		-D BUILD_GENERATOR=$(usex generator)
		-D DEVELOPER_BUILD=$(usex debug)
	)

	cmake_src_configure
}
