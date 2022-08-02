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

## functions: get_udevdir
inherit udev

DESCRIPTION="An interface for filesystems implemented in userspace"
LICENSE="GPL-2 LGPL-2.1"

SLOT="3"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( test )

CDEPEND_A=(

)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"sys-fs/fuse-common"
)

inherit arrays

src_prepare() {
	default

	# lto not supported yet -- https://github.com/libfuse/libfuse/issues/198
	filter-flags -flto*

	# passthough_ll is broken on systems with 32-bit pointers
	cat /dev/null > example/meson.build || die
}

src_install() {
	meson_src_install

	DOCS=( AUTHORS ChangeLog.rst README.md doc/README.NFS doc/kernel.txt )
	einstalldocs

	### installed via fuse-common
	rrm -r "${ED}"/etc
	rrm -r "${ED}"/$(get_udevdir)

	rrm "${ED}"/usr/sbin/mount.fuse*
	rrm "${ED}"/usr/share/man/*/mount.fuse*

	### handled by the device manager
	rrm -r "${ED}"/dev
}
