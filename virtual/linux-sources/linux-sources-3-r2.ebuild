# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual for Linux kernel sources"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="firmware"

RDEPEND="
	firmware? ( sys-kernel/linux-firmware )
	|| (
		sys-kernel/sabayon-sources
		sys-kernel/odroid-sources
		sys-kernel/e-sources
		sys-kernel/pentoo-sources
		sys-kernel/backbone-sources
		sys-kernel/calculate-sources
		sys-kernel/bliss-kernel
		sys-kernel/gentoo-sources
		sys-kernel/vanilla-sources
		sys-kernel/ck-sources
		sys-kernel/git-sources
		sys-kernel/hardened-sources
		sys-kernel/minipli-sources
		sys-kernel/lh-sources
		sys-kernel/mips-sources
		sys-kernel/chromeos-sources
		sys-kernel/pf-sources
		sys-kernel/rt-sources
		sys-kernel/vserver-sources
		sys-kernel/xbox-sources
		sys-kernel/zen-sources
		sys-kernel/aufs-sources
		sys-kernel/raspberrypi-sources
		sys-kernel/reiser4-sources
		sys-kernel/adafruit-raspberrypi-sources
		sys-kernel/drm-raspberrypi-sources
		sys-kernel/nouveau-sources
		sys-kernel/bone-sources
	)"
