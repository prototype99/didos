# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:libfuse:libfuse"
GH_REF="fuse-${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson

## functions: filter-flags
inherit flag-o-matic

## functions: udev_newrules
inherit udev

DESCRIPTION="Common files for multiple slots of sys-fs/fuse"
LICENSE="GPL-2 LGPL-2.1"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=()

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!<sys-fs/fuse-2.9.7-r1:0"
)

# tests run in sys-fs/fuse
RESTRICT+=" test"

inherit arrays

src_prepare() {
	eapply_user

	# do not build unneeded targets
	rsed -r -e "/^subdirs *=/ s/'(lib|include|example|doc|test)',?//g" -i -- meson.build

	# lto not supported yet -- https://github.com/libfuse/libfuse/issues/198
	filter-flags -flto*
}

src_install() {
	newsbin "${BUILD_DIR}"/util/mount.fuse3 mount.fuse
	doman doc/mount.fuse.8

	udev_newrules util/udev.rules 99-fuse.rules

	insinto /etc
	doins util/fuse.conf
}
